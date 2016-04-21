function [result status] = perl(varargin)
%PERL Execute Perl command and return the result.
%   PERL(PERLFILE) calls perl script specified by the file PERLFILE
%   using appropriate perl executable.
%
%   PERL(PERLFILE,ARG1,ARG2,...) passes the arguments ARG1,ARG2,...
%   to the perl script file PERLFILE, and calls it by using appropriate
%   perl executable.
%
%   RESULT=PERL(...) outputs the result of attempted perl call.  If the
%   exit status of perl is not zero, an error will be returned.
%
%   [RESULT,STATUS] = PERL(...) outputs the result of the perl call, and
%   also saves its exit status into variable STATUS. 
% 
%   If the Perl executable is not available, it can be downloaded from:
%     http://www.cpan.org
%
%   See also SYSTEM, JAVA, MEX.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $

cmdString = '';

% Add input to arguments to operating system command to be executed.
% (If an argument refers to a file on the MATLAB path, use full file path.)
for i = 1:nargin
  thisArg = varargin{i};
  if isempty(thisArg) | ~ischar(thisArg)
    error(['All input arguments must be valid strings.']);
  elseif exist(thisArg)==2
    % This is a valid file on the MATLAB path
    if isempty(dir(thisArg))
      % Not complete file specification
      % - file is not in current directory
      % - OR filename specified without extension
      % ==> get full file path
      thisArg = which(thisArg);
    end
  elseif i==1
    % First input argument is PerlFile - it must be a valid file
    error(['Unable to find Perl file: ', thisArg]);
  end
  
  % Wrap thisArg in double quotes if it contains spaces
  if any(thisArg == ' ')
    thisArg = ['"', thisArg, '"'];
  end
  
  % Add argument to command string
  cmdString = [cmdString, ' ', thisArg];
end

% Execute Perl script
errTxtNoPerl = 'Unable to find Perl executable.';

if isempty(cmdString)
  error('No perl command specified');
elseif ispc
  % PC
  perlCmd = fullfile(matlabroot, 'sys\perl\win32\bin\');
  cmdString = ['perl' cmdString];
  perlCmd = ['set PATH=',perlCmd, ';%PATH%&' cmdString];
  [status, result] = dos(perlCmd);
else
  % UNIX
  [status, perlCmd] = unix('which perl');
  if (status == 0)
    cmdString = ['perl', cmdString];
    [status, result] = unix(cmdString);
  else
    error(errTxtNoPerl);
  end
end

% Check for errors in shell command
if nargout < 2 && status~=0
  error(['System error: ', result, ...
      'Command executed: ', cmdString]);
end

