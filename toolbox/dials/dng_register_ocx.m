function dng_register_ocx(ur_str,alt_root)
%DNG_REGISTER_OCX (Un)Registers the Dials & Gauges ActiveX controls.
%   This function is only for use on Windows systems.
%   DNG_REGISTER_OCX registers the controls with MS-Windows.
%   DNG_REGISTER_OCX /u unregisters the controls.

%   DNG_REGISTER_OCX (/u) <alternate_matlabroot> uses an alternate
%   MATLAB root as the place to find the *.ocx files. These files
%   must be in the <alternate_matlabroot>\toolbox\dials\ocx
%   directory. This works for both registering and unregistering
%   controls. Just leave the second argument empty to allow
%   registration from this alternate location.
%
%   Copyright 1998-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $  $Date: 2003/12/15 15:53:19 $

if ~( strcmp( computer,'PCWIN') )
	return;
end
		
if (nargin >= 1)
  if ~isempty(ur_str) & ~strcmp(ur_str, '/u')
	error('Invalid parameter');
  end
else
  ur_str=[];
end

if (nargin >= 2)
  root = alt_root;
else
  root = matlabroot;
end

ocx_path = [root '\toolbox\dials\ocx'];
cur_path = cd;

cd([matlabroot '\bin\win32']);

ocx_dir = dir([ocx_path '\*.ocx']);
ocx_fns = {ocx_dir.name};

if isempty(ur_str)
  disp(sprintf(['\nBegin registering ActiveX controls ...\n']))
end

for i = 1:length(ocx_fns)
  [failure, result] = dos(['regsvr32 /c /s ' ur_str ' ' ...
		    [ocx_path '\' ocx_fns{i}] ]);
  
  % Check to see if registration was not successful
  if (failure)
    warning(sprintf(['Registration of %s failed.\n' ...
		     'System error message:\n%s\n' ...
		     'Contact The MathWorks at support@mathworks.com ' ...
		     'or visit this URL for more info:\n\n' ...
		     'http://www.mathworks.com/support/solutions/data/24876.shtml\n'], ...
		     ocx_fns{i}, result))
  end

end

if isempty(ur_str)
  disp(sprintf(['\nFinished registering ActiveX controls']))
end

% Copy config.gms to the system directory if registering.
% If unregistering, don't copy and don't remove it since
% the user may have modified it.
if isempty(ur_str)
  % Get the location of the system directory
  sysdir = dng_getsysdir;

  % Copy the file
  if ~isempty(sysdir)
    
    % Perform the copy and make the destination file writable.
    disp(sprintf(['\nCopying config.gms to system directory: ' ...
		  '%s\n', ...
		  'and making the file writable.\n'],sysdir))
    [success, result] = copyfile([ocx_path '\' 'config.gms'], sysdir, 'writable');

    % Check the success of the copy
    if ~success
      warning(sprintf(['\nCopy of config.gms failed\n', ...
		       'Attempted to copy config.gms from ', ...
		       '"%s\\toolbox\\dials\\ocx"\nto "%s" ', ...
		       'and make the file writable.\n', ...
		       'Please do this manually.\n', ...
		       'System error message:\n%s'],matlabroot,sysdir,result))
    end

  else
    % Warn if couldn't find the system directory
    warning(sprintf(['\nCouldn''t find correct system directory to copy' ...
		     ' config.gms into.\n']))
    
  end
  
end

cd(cur_path)






