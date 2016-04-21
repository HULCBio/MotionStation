function errorCode = installmcr(varargin)
%INSTALLMCR	installs the MCR. It is a wrapper. 
%
%   On UNIX it calls a Bourne shell script which does all the work. 
%   On the PC it prints instructions to do the installation manually.
%
%   Command Line Options:
%
%     UNIX/Linux/Mac: (supported by the installmcr script)
%
%       -help            - Help.
%
%       -r mcr_root      - Specify the path to the root of the MCR. If
%                          not specified on the command line query the
%                          user. If the path does not exist, try to
%                          create it.
%
%        mcr_zipfile      - Specify the path to the Zip file for the MCR.
%                           If none specified, it tries to use:
%
%          $MATLAB/toolbox/compiler/deploy/$ARCH/MCRInstaller.zip
%
%     PC: (none)

%   $Revision: 1.1.6.3 $  $Date: 2004/01/19 02:56:24 $
%   Copyright 2004 The MathWorks, Inc.
%-----------------------------------------------------------------------

if isunix
  if (nargin > 0)
    args = sprintf(' "%s"', varargin{:});
  else
    args = '';
  end
  errorCode = unix([matlabroot '/toolbox/compiler/installmcr' args]);
elseif ispc
%
% Give manual instructions for now
%
  disp('-----------------------------------------------------------------------');
  disp('-> Instructions to install the MCR manually on Windows:');
  disp(' ');
  disp('   Assumption: Unzip utility like WinZip has been installed');
  disp('               on your system.' );
  disp(' ');
  disp('   In the file manager:');
  disp(' ');
  disp('   1. Navigate to the directory:');
  disp(' ');
  disp('          $MATLAB\toolbox\compile\deploy\win32');
  disp(' ');
  disp('   2. Double clink on the file:');
  disp(' ');
  disp('          MCRInstaller.zip');
  disp(' ');
  disp('   3. Install using the utility.');
  disp('-----------------------------------------------------------------------');
  errorCode = 0;
end
