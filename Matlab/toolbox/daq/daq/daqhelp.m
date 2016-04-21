function varargout = daqhelp(varargin)
%DAQHELP Display Data Acquisition Toolbox help.
%
%    DAQHELP provides a complete listing of Data Acquisition Toolbox
%    functions with a brief description of each function.
%
%    DAQHELP('NAME') provides on-line help for the function or property,
%    NAME.  If NAME is the name of a data acquisition object, a complete
%    listing of functions and properties for the data acquisition object, 
%    NAME, is displayed with a brief description of each function and 
%    property.  The on-line help for the object's constructor is also 
%    displayed.  If NAME is the name of a data acquisition object (with
%    a .m extension) the on-line help for the object's constructor is 
%    displayed.
%
%    OUT = DAQHELP('NAME') returns the help text in string, OUT.
%
%    Object specific function information can be displayed by specifying
%    NAME to be object/function.  For example to display the on-line
%    help for an analog input object's GETDATA function, NAME would be
%    analoginput/getdata.
%
%    Object specific property information can be displayed by specifying
%    NAME to be object.property.  For example to display the on-line help
%    for an analog input object's SampleRate property, NAME would be
%    analoginput.SampleRate.
%
%    DAQHELP(OBJ) displays a complete listing of functions and properties
%    for the data acquisition object, OBJ, along with the on-line help
%    for the object's constructor.
%
%    DAQHELP(OBJ, 'NAME') displays the help for function or property, NAME,
%    for the data acquisition object, OBJ.
%
%    OUT = DAQHELP(OBJ, 'NAME') returns the help text in string, OUT.
%
%    When displaying property help, the names in the See also section which
%    contain all upper case letters are function names.  The names which
%    contain a mixture of upper and lower case letters are property names.
%
%    When displaying function help, the see also section contains only 
%    function names.
%
%    Example:
%       daqhelp('analogoutput')
%       out = daqhelp('analogoutput.m');
%       daqhelp set
%       daqhelp analoginput/peekdata
%       daqhelp analoginput.TriggerDelayUnits
%       
%       ai = analoginput('winsound');
%       daqhelp(ai)
%       daqhelp(ai, 'InitialTriggerTime');
%       out = daqhelp(ai, 'getsample');
%       daqhelp(ai, 'set');
% 
%    See also PROPINFO.
%

%    MP 8-04-98   
%    Copyright 1998-2004 The MathWorks, Inc.
%    $Revision: 1.13.2.7 $  $Date: 2004/03/30 13:03:46 $

ArgChkMsg = nargchk(0,2,nargin);
if ~isempty(ArgChkMsg)
    error('daq:daqhelp:argcheck', ArgChkMsg);
end
if nargout > 1,
   error('daq:daqhelp:argcheck', 'Too many output arguments.')
end

% Find the directory where the toolbox is installed.
daqroot = which('daqmex.dll', '-all');
daqroot = fileparts(daqroot{1});

switch nargin
case 0
    % No input parameters, just give general help from contents.m
    if nargout==1,
        varargout{1} = help(daqroot);
    else
        help(daqroot);
    end
   return;
case 1
   % 1 input parameter.  Could be a DAQ object, could be a name
   % Initialize variables.
   str = varargin{1};
   fullpath = {''};
   isdir = [];
   parent = '';
   device=[];
   
   % Check first argument to see if it is a Data Acquisition object. 
   if ~ischar(str)
      if isa(str, 'daqdevice') || isa(str, 'daqchild')
         path = '';
         name = class(str);
         ext = '';
         % Yes -- it's a DAQ object.  It corresponds to the contents.m
         % in a subdirectory
         isdir = 1;
      else
         error('daq:daqhelp:argcheck', 'The first input argument must be a string or a data acquisition object.');
      end
   else
      % Determine if user specified an extension and/or a path.
      [path,name,ext] = fileparts(str);
   end
   
   % Determine if the name specified is a directory.
   if isempty(isdir)
      isdir = localIsDir(lower(name),daqroot);
      % isdir will be nonzero if it is a directory
   end
   
   % If the name is a directory, fullpath contains the full path to the
   % contents help and constructor help (if it is not daq).
   % Ex. "daqhelp daq" or "daqhelp analoginput"
   if isdir && isempty(ext)
      if strcmp(lower(name), 'daq')
         fullpath = {daqroot};
      elseif strcmp(name(1), '@')
         fullpath = {[daqroot filesep name]};
      else
         fullpath = {[daqroot filesep name]};
         % !!! Do we do this because there might be two different
         % possibilities?  One with the @, and one without?
         fullpath = {fullpath{:}, [daqroot filesep '@' name filesep name '.m']};
      end
   end
   
   % If the extension is not a .m, a property was provided and privatePropDesc
   % is called.  If privatePropDesc fails, property was invalid.
   % Ex. "daqhelp analoginput.Logging"
   if ~isempty(ext) && ~strcmp(ext, '.m') 
      try
         [errflag, out] = daqgate('privatePropDesc', ext(2:end),name);
      catch
         error('daq:daqhelp:invalidproperty', 'Invalid data acquisition function or property: ''%s''.', varargin{1});
      end
      % Error if privatePropDesc errored expectedly.
      if errflag
         error('daq:daqhelp:invalidproperty', lasterr)
      elseif nargout == 0
         fprintf('\n');
         fprintf(out);
         fprintf('\n');
      else
         varargout{1} = out;
      end
      return;
   end
   
   % Determine the full path, if one was not provided.
   if isempty(fullpath{1})
      % Get all the locations of the file.
      temppath = which(name, '-all');
      % Determine the parent directory - path:analoginput, parent:daqdevice.
      if ~isempty(path)
         parent = localFindParent(path);
      end
      % Loop through temppath and find the requested path.
      for i = 1:length(temppath)
         % Ex. daqhelp analoginput/getsample.
         if ~isempty(path) && any(findstr([daqroot '\@' path], temppath{i}))
            fullpath = temppath(i);
            break;
         elseif any(findstr([daqroot '\' name], temppath{i}))
            fullpath = temppath(i);
            break;
         end
         
         % Ex. daqhelp analoginput/set
         if ~isempty(parent) && any(findstr([daqroot '\@' parent], temppath{i}))
            fullpath = temppath(i);
            break;
         elseif any(findstr([daqroot '\' name], temppath{i}))
            fullpath = temppath(i);
            break;
         end
         
         % Ex. daqhelp isvalid
         if isempty(path)&& (any(findstr([daqroot '\@daqdevice\' name], temppath{i})) ||...
               (any(findstr([daqroot '\@daqchild\' name], temppath{i}))) || ...
               (any(findstr([daqroot '\private\' name], temppath{i}))))
            fullpath = temppath(i);
            break;
         end
         
         % Ex. daqhelp private\save
         if any(findstr('private', path))
            if (any(findstr([daqroot '\private\' name], temppath{i})))
               fullpath = temppath(i);
               break;
            end
         end
         
         % Ex. daqhelp daqdemos\daqscope
         if any(findstr('daqdemos', path))
            if (any(findstr([daqroot '\daqdemos\' name], temppath{i})))
               fullpath = temppath(i);
               break;
            end
         end

         % Ex. daqhelp daq\@daqdevice\isvalid
         if any(findstr('daq\', path))
            if (any(findstr([daqroot(1:end-3) path '\' name], temppath{i})))
               fullpath = temppath(i);
               break;
            end
         end
         
         % Ex. daqhelp analoginput.m
         if isempty(path) && isempty(parent)
            if (any(findstr(daqroot, temppath{i})))
               fullpath = temppath(i);
               break;
            end
         end
      end %for i = 1:length(temppath)
   end %isempty(fullpath{1})
case 2
   % Error if the first input is not a daqdevice or daqchild object.
   if ~(isa(varargin{1}, 'daqdevice') || isa(varargin{1}, 'daqchild'))
      % If the input is not a string, error with the class name.
      if ~ischar(varargin{1})
         varargin{1} = class(varargin{1});
      end
      if ~ischar(varargin{2})
         varargin{2} = class(varargin{2});
      end
      error('daq:daqhelp:invalidproperty', 'Invalid data acquisition function or property: ''%s'' ''%s''.', varargin{1}, varargin{2} );
   end
   
   if ~ischar(varargin{2})
      error('daq:daqhelp:argcheck', 'The second input argument must be a string.');
   end

   
   % Initialize variables.
   name = varargin{2};
   path = class(varargin{1});  
   device = varargin{1};
   driver = path;
       
   % Find the fullpath.  First assume the name is not inherited.  If that
   % fails, assume the name is inherited.
   % Ex. "daqhelp(ai, 'Peekdata')",  "daqhelp(ai, 'set')"
   fullpath = {which([path '\' name])};
   if isempty(fullpath{1})
      parent = localFindParent(path);
      fullpath = {which([parent '\' name])};
   end
   
   % Determine if function is in the daq directory.
   % Ex. "daqhelp(ai, 'daqread')"
   if isempty(fullpath{1})
      fullpath = {which([daqroot filesep name])};
   end
end

% If path is empty either NAME is a property or NAME is invalid.
if isempty(fullpath{1}) && (nargin == 2 || (nargin == 1 && isempty(path)))
    % Ex. "daqhelp Logging", "daqhelp(ai, 'Logging')"
    try
        [errflag, out] = daqgate('privatePropDesc',name,path);
        %try to determine if the propertiy is a valid member of input
        if ~isempty(device) && ~errflag
            try
                get(device,name);
            catch
                lasterr( ['The ''' name ''' property is invalid for ''' driver ''' objects.']);
                errflag=1;
            end;
        end
    catch
        if isempty(path)
            error('daq:daqhelp:invalidproperty', 'Invalid data acquisition function or property: ''%s''.', name);
        else
            error('daq:daqhelp:invalidproperty', 'Invalid data acquisition function or property: ''%s.%s''.',  path, name);
        end
    end
    % Error if privatePropDesc errored expectedly.
    if errflag
        error('daq:daqhelp:invalidproperty', lasterr);
    elseif nargout == 0
        fprintf('\n');
        fprintf(out);
        fprintf('\n');
    else
        varargout{1} = out;
    end
    return;
elseif isempty(fullpath{1}) && nargin == 1
    % Ex. "daqhelp analoginput/Logging"
   error('daq:daqhelp:invalidproperty', 'Invalid data acquisition function or property: ''%s''.',  varargin{1});
else
   % By this point, we've either got a path to the directory that we're going
   % to use the content.m of, or the .m file that we're going to use.

   % If the name is daqmex, the fullpath may be to the .dll.  Therefore
   % need to replace the .dll with a .m so the correct help is called.
   if strcmp(name, 'daqmex')
      fullpath = strrep(fullpath, '.dll', '.m');
   end
   % Call help on each fullpath string.
   outTemp = [];
   for i = 1:length(fullpath)
      if nargout == 0
         out = evalc('help(fullpath{i})');
         fprintf('\n');
         fprintf(out);
         fprintf('\n');
      else
         out = help(fullpath{i});
         outTemp = [outTemp out];
      end
   end
   if nargout == 1
      varargout{1} = outTemp;
   end
end

% ********************************************************************
% Determine if the name specified is a directory.
function out = localIsDir(name,daqroot)

% If the name is daq return 1.
if strcmp(name, 'daq')
   out = 1;
   return;
end

% Add the @ to the name if it isn't included.
if ~strcmp(name(1), '@')
   name = ['@' name];
end

% Get all the directory names in the Data Acquisition toolbox.
d = dir(daqroot);
names = {d.name};
dirnames = {names{find([d.isdir])}};

% Determine if name is one of the directories in the toolbox.
out = find(strcmp(name, dirnames));
if isempty(out)
   out = 0;
end;

% ********************************************************************
% Determine the parent of the pathname specified.
function out = localFindParent(name)

% Initialize variables.
out = '';

% If the name is daq return 1.
if strcmp(name, 'daq') || isempty(name)
   out = '';
   return;
end

% Add the @ to the name if it isn't included.
if strcmp(name(1), '@')
   name = name(2:end);
end

if any(strcmp(lower(name), {'analoginput', 'analogoutput', 'digitalio'}))
   out = 'daqdevice';
   return;
elseif any(strcmp(lower(name), {'aichannel', 'aochannel', 'dioline'}))
   out = 'daqchild';
end
