function obj2mfile(obj, varargin)
%OBJ2MFILE Convert data acquisition object to MATLAB code.
%
%    OBJ2MFILE(OBJ, 'FILENAME') converts the data acquisition object, OBJ
%    to the equivalent MATLAB code using the SET syntax and saves the 
%    MATLAB code to the specified FILENAME.  If an extension is not specified, 
%    the .m extension is used.  By default, only those properties that 
%    are not set to their default values are written to the file, FILENAME.
%    OBJ can be a single data acquisition object or an array of objects.
%
%    OBJ2MFILE(OBJ, 'FILENAME', SYNTAX) converts the data acquisition object,
%    OBJ, to the equivalent MATLAB code using the specified SYNTAX and saves
%    the code to FILENAME.  The SYNTAX can be 'set', 'dot' or 'named'.  If
%    SYNTAX is not specified, 'set' is used as the default.
%
%    OBJ2MFILE(OBJ, 'FILENAME', 'all')
%    OBJ2MFILE(OBJ, 'FILENAME', SYNTAX, 'all') saves the equivalent MATLAB 
%    code created with the specified SYNTAX to FILENAME.  If 'all' is 
%    included, all properties are written to FILENAME.  If 'all' is excluded, 
%    only those properties not set to their default values are written to 
%    FILENAME.
%
%    If OBJ's UserData is not empty, then the data stored in the UserData
%    property is written to a MAT-file when the object is converted and
%    saved.  The MAT-file has the same name as the M-file containing the 
%    object code.
%
%    If any of OBJ's callback properties are set to a cell array, then the
%    data stored in that callback property is written to a MAT-file when
%    the object is converted and saved.  The MAT-file has the same name
%    as the M-file containing the object code.
%
%    To recreate OBJ, if OBJ is a device object, type the name of the
%    M-file.  To recreate OBJ, if OBJ is a channel or line object, type
%    the name of the M-file with a device object as the only input.
%
%    Example:
%       ai = analoginput('winsound');
%       chan = addchannel(ai, [1 2], {'Temp1';'Temp2'}); 
%       set(ai, 'Tag', 'myai', 'TriggerRepeat', 4);
%
%       % To save ai:
%         obj2mfile(ai, 'myai.m', 'dot');
%       % To recreate ai:
%         copyai = myai;
%
%       % To save chan:
%         obj2mfile(chan, 'mychan', 'all');
%       % To recreate chan:
%         newai = analoginput('winsound');
%         copychan = mychan(newai);
%
%    See also DAQHELP.
%

%    MP 5-12-98
%    Copyright 1998-2003 The MathWorks, Inc.
%    $Revision: 1.3.2.5 $  $Date: 2003/10/15 18:27:58 $

ArgChkMsg = nargchk(1,4,nargin);
if ~isempty(ArgChkMsg)
    error('daq:obj2mfile:argcheck', ArgChkMsg);
end
% Error if an invalid object was passed.
if ~all(isvalid(obj))
   error('daq:obj2mfile:invalidobject', 'Data acquisition object OBJ is an invalid object.');
end

% Initialize variables.
name = inputname(1);
time = datestr(now);

% Determine if the correct input was passed.
try
   [errflag,syntax,definelist,filename,file,path] = ...
      daqgate('getfileinfo',varargin{:});
catch
   error('daq:obj2mfile:unexpected', lasterr)
end
   
% Error if an error occurred in getfileinfo.
if errflag
   error('daq:obj2mfile:unexpected', lasterr)
end

% Define the 'name' variable in case ai.Channel is passed as the input.
if isempty(name)
   name = 'temp';
end

% Rename the classname so that it looks better in the comments of the
% constructed M-file.  Define if addchannel or addline will be called.
% Define the parent object so that a default child object can be created
% to determine the default property values. Define the child type for 
% the comments.
hinfo = struct(daqmex(obj, 'get', 'Parent'));
cmd = hinfo.info.addchild;
parent_obj = lower(hinfo.info.objtype);
type_child = hinfo.info.child;

% Remove the space from parent_obj (analog input ==> analoginput)
parent_obj(find(parent_obj == ' ')) = [];

% Open the file.
fid = fopen(filename, 'w');

% Check if the file was opened successfully.
if (fid < 3)
   error('daq:obj2mfile:fileopen', '%s could not be opened.', filename);
end

% Obtain the handle to the parent object
try
   parent = daqmex(obj,'get','parent');
catch
   error('daq:obj2mfile:unexpected', lasterr)
end

% so that the DriverName and ID can be obtained.
hwinfo = daqhwinfo(parent);
drivername = hwinfo.AdaptorName;
hwid = hwinfo.ID;

% Create the string for the object's constructor which is used in the
% example in the comments.
if isempty(hwid) 
   commentdriver = ['''' drivername ''''];
else
   commentdriver = ['''' drivername ''',' hwid ];
end

% Write function line and comments to the file.
fprintf(fid, 'function out = %s(parent)\n', file);
localSetComment(fid,file,parent_obj,type_child,commentdriver,name);

% Write a comment indicating when the file was created.
fprintf(fid, '%%    Creation time: %s\n\n', time);

% Write out error check on input arguments.
fprintf(fid, '%% Error if input is incorrect.\n');
fprintf(fid, 'if (nargin ~= 1) | ~isa(parent, ''daqdevice'')\n');
fprintf(fid, '   error([''One device object is expected as input.  '',...\n');
fprintf(fid, '         ''See the on-line help for an example.'']);\n');
fprintf(fid, 'end\n\n');

% Create the parent object so that the list of default children properties
% can be obtained.
if isempty(hwid) 
   testobj = feval(parent_obj, drivername);
else
   testobj = feval(parent_obj, drivername, hwid);
end

% Write out the commands to reconstruct the channel/line objects.
try
   errflag = daqgate('privatewritechild',fid,syntax,definelist,obj,testobj,name,...
      'parent',type_child,cmd);
catch
   error('daq:obj2mfile:unexpected', lasterr);
end

% Error if privatewritechild errored expectedly.
if errflag
   error('daq:obj2mfile:unexpected', lasterr);
end

% Output the Data Acquisition object if an output variable is specified.
fprintf(fid, 'if nargout > 0, out = %s; end;\n', name);

% Close the file.
fclose(fid);

% Display message that the specified file was created.
if isempty(path)
   filename = [pwd '\' filename];
end
disp(['Created: ' filename]);

% Delete the parent object, testobj.
delete(testobj)
   
% **********************************************************************
% Create the comments for the beginning of the M-file.
function localSetComment(fid,file,parent_obj,type_child, commentdriver,name)

fprintf(fid,['%%' upper(file) ' M-Code for creating an array of ' type_child ' objects.\n',...
      '%%    \n',...
      '%%    ' upper(file) '(PARENT) appends the array of ' type_child ' objects defined\n',...
      '%%    in ' upper(file) ' to the Data Acquisition object, PARENT.\n',...
      '%%    \n',...
      '%%    This is the machine generated representation of a ' type_child ' object.\n',...
      '%%    This M-file was generated from the OBJ2MFILE function.  To recreate \n',...
      '%%    the ' type_child ' object, type the name of the M-file, ' upper(file),...
             ', at the MATLAB \n',... 
      '%%    command prompt and pass a PARENT object as input.  The PARENT object\n',... 
      '%%    should be of class ''' parent_obj '''.\n',...
      '%%    \n',...
      '%%    The M-file, ' upper(file) ', must be on your MATLAB PATH.  For additional\n',...
      '%%    information on setting your MATLAB PATH, type ''help addpath'' at the\n',...
      '%%    MATLAB command prompt.\n',...
      '%%    \n',...
      '%%    Example:\n',...
      '%%       parent = ' parent_obj '(' commentdriver ');\n',...
      '%%       ' name ' = ' lower(file) '(parent);\n',...
      '%%    \n',...
      '%%    See also ANALOGINPUT, ANALOGOUTPUT, DIGITALIO, ADDCHANNEL, ADDLINE\n',...
      '%%    DAQHELP, PROPINFO.\n',...
      '%%    \n\n']);


