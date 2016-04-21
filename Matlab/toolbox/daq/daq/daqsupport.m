function daqsupport(varargin)
%DAQSUPPORT Debugging utility.
% 
%    DAQSUPPORT('ADAPTOR'), where ADAPTOR is the name of the data 
%    acquisition card you are using, returns diagnostic information to 
%    help troubleshoot setup problems.  Output is saved in a text file, 
%    DAQTEST.
%
%    DAQSUPPORT('ADAPTOR','FILENAME'), saves the results to the text file 
%    FILENAME.  
% 
%    DAQSUPPORT tests all installed hardware adaptors.
% 
%    Examples:
%       daqsupport('winsound')
%       daqsupport('winsound','myfile.txt')

%   SM 4-15-99
%   Copyright 1998-2003 The MathWorks, Inc.
%   $Revision: 1.8.2.4 $  $Date: 2003/08/29 04:40:55 $

OldWarningState = warning;
warning off backtrace;

filename = 'daqtest.txt';

switch nargin,
case 0,
   hwInfo=daqhwinfo;
   adaptors=hwInfo.InstalledAdaptors;
case 1,
   adaptors=varargin(1);
case 2,
   adaptors=varargin(1);
   filename = varargin{2};
otherwise,
    ArgChkMsg = nargchk(0,2,nargin);
    if ~isempty(ArgChkMsg)
        error('daq:daqsupport:argcheck', ArgChkMsg);
    end
end % switch

% Check that adaptor string is contained in a cell.
if ~iscellstr(adaptors),
    error('daq:daqsupport:argcheck', 'ADAPTOR must be specified as a string.')
    warning(OldWarningState);
    return;
end

if exist(filename,'file')
   delete(filename);
end % if

try
   fid = fopen(filename,'w');
   if fid==-1,
       error('') % This error message is not displayed
   end
catch
   error('daq:daqsupport:fileopen', 'Can''t open file ''%s'' for writing.', filename);
    warning(OldWarningState);
    return;
end % try

dispCapture = [];
cr = sprintf('\n');
sp = sprintf('%s','----------');

% MATLAB and Data Acquision Toolbox version

vOS=evalc('!ver');
vOS=vOS(3:end);
dispCapture = [dispCapture evalc('disp([cr,''Operating System: '']);disp(vOS)')];

[v,d] = version;  % MATLAB version information
dispCapture = [dispCapture evalc('disp([cr,''MATLAB version: '']);disp(v)')];

daqver = ver('daq'); % Data Acquistion version information
dispCapture = [dispCapture evalc('disp([cr,''Data Acquisition Toolbox version: '']); disp(daqver)')];

% MATLABROOT directory

root = matlabroot;
% Display to screen
dispCapture = [dispCapture evalc('disp([cr,sp,''MATLAB root directory: '',sp]);disp(root)')];

% MATLAB path
% Display to screen
dispCapture = [dispCapture evalc('disp([cr,sp,''MATLAB path: '',sp]);path')];

for lp=1:length(adaptors),
   % Display adaptor being tested %
   dispCapture = [dispCapture evalc('disp([cr,sp,''Testing '' adaptors{lp} '' adaptor for:'',sp])')];
   
   % DAQ Hardware info
   
   try 
      dispCapture = [dispCapture evalc(['disp([cr,sp,''Registering adaptor: '' adaptors{lp},sp]),',...
              'daqregister(adaptors{lp});',...
              'disp([cr,''Successfully registered '' adaptors{lp} '' adaptor''])'])];
   catch
      dispCapture = [dispCapture evalc(['disp([cr,''Error registering '' adaptors{lp} '' adaptor'']),',...
              'disp([cr,lasterr])'])];
   end % try
   
   out = daqhwinfo; % display available hardware
   dispCapture = [dispCapture evalc(['disp([cr,sp,''Available hardware: '',sp,cr]);disp(out),',...
           'disp([cr,sp,''Toolbox Version: '',sp,cr]);disp(out.ToolboxVersion)'])];
   
   try
      dispCapture = [dispCapture evalc(['disp([cr,sp,''Adaptor Information for adaptor '',adaptors{lp},sp,cr]),',...
                  'adaptorInfo=daqhwinfo(adaptors{lp})'])];
      if ~isempty(adaptorInfo)
         dispCapture = [dispCapture evalc(['disp([cr,sp,''Adaptor DLL Name'',sp,cr]);disp(adaptorInfo.AdaptorDllName),',...
                     'disp([cr,sp,''Adaptor Name'',sp,cr]);disp(adaptorInfo.AdaptorName)'])];
         for inLp2 = 1:numel(adaptorInfo.ObjectConstructorName)
            dispCapture = [dispCapture evalc('disp([cr,sp,''Object Constructor Name '',sp,cr]);disp(adaptorInfo.ObjectConstructorName{inLp2})')];
         end % for
      end % if
   catch
      dispCapture = [dispCapture evalc('disp([cr,''Error displaying DAQHWINFO for adaptor '',adaptors{lp}])')];
      dispCapture = [dispCapture evalc('disp(lasterr)')];
      adaptorInfo = [];
   end % try
   
   % Test Analoginput, Analogoutput, Digital I/O objects
   loc = [];
   
   device={'analoginput','analogoutput','digitalio'};
   for inLp=1:length(device),
      if ~isempty(adaptorInfo)
         loc=find(strncmp(device{inLp},adaptorInfo.ObjectConstructorName,length(device{inLp})));
      end
      if ~isempty(loc),
         try
            dispCapture = [dispCapture evalc('disp([cr,sp,''Creating '' device{inLp} '' object for adaptor '' adaptors{lp},sp])')];
            b=eval(adaptorInfo.ObjectConstructorName{loc(1)});
            dispCapture = [dispCapture evalc('daqhwinfo(b)')];
            delete(b);
         catch
            dispCapture = [dispCapture evalc('disp([cr,''Error creating '' device{inLp} '' object for adaptor'' adaptors{lp}])')];
            dispCapture = [dispCapture evalc('disp(lasterr)')];
         end % try
      end %if
   end % for
   
end % for

dispCapture = [dispCapture evalc(['disp([cr,sp,sp,''End test'',sp,sp]),',...
            'disp([cr,''This information has been saved in the text file:'',cr,filename]),',...
            'disp([cr,''If any errors occurred, please e-mail this information to:'',cr,''support@mathworks.com''])'])];

fprintf(fid,'%s',dispCapture);,
fclose(fid);

warning(OldWarningState);

edit(filename)
% end daqsupport