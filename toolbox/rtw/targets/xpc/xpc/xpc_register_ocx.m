function xpc_register_ocx(ur_str,alt_root)

%XPC_REGISTER_OCX (Un)Registers the xPC Target Explorer ActiveX controls.
%   This function is only for use on Windows systems.
%   XPC_REGISTER_OCX registers the controls with MS-Windows.
%   XPC_REGISTER_OCX /u unregisters the controls.

%   XPC_REGISTER_OCX (/u) <alternate_matlabroot> uses an alternate
%   MATLAB root as the place to find the *.ocx files. These files
%   must be in the <alternate_matlabroot>\toolbox\xpc\xpcmngr\ocx
%   directory. This works for both registering and unregistering
%   controls. Just leave the second argument empty to allow
%   registration from this alternate location.
%
%   Copyright 1998-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:25:14 $

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

ocx_path = [root '\toolbox\rtw\targets\xpc\xpc\xpcmngr'];
cur_path = cd;

cd([matlabroot '\bin\win32']);

ocx_dir = dir([ocx_path '\ocx\*.OCX']);
ocx_fns = {ocx_dir.name};
ocx_fns{end+1}='ccrpTmr6.dll';
% dll_dir = dir([ocx_path '\*.ocx']);
% dll_fns = {ocx_dir.name};
if isempty(ur_str)
  disp(sprintf(['\nBegin registering ActiveX controls ...\n']))
end

for i = 1:length(ocx_fns)
  [failure, result] = dos(['regsvr32 /c /s ' ur_str ' ' ...
		    [ocx_path '\ocx\' ocx_fns{i}] ]);
  
  % Check to see if registration was not successful
  if (failure)
    warning(sprintf(['Registration of %s failed.\n' ...
		     'System error message:\n%s\n'], ...
              ocx_fns{i}, result))
  end

end

if isempty(ur_str)
  disp(sprintf(['\nFinished registering ActiveX controls']))
end


cd(cur_path)