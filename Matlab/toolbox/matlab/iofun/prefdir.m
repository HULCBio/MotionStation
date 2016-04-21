function dd_out = prefdir(createIfNecessary)
%PREFDIR Preference directory name.
%   D = PREFDIR(CREATEIFNECESSARY) returns a platform specific preference
%   directory name which may contain user specific tool helper files such
%   as mexopts.bat etc.
%
%   D = PREFDIR(1) creates the directory if it doesn't exist.
%   D = PREFDIR or D = PREFDIR(0) merely returns the directory name
%   without ensuring its existence. 
%
%   See also GETPREF, SETPREF.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.3 $  $Date: 2004/04/10 23:29:31 $

persistent dd;

if(nargin<1)
   createIfNecessary = 0;
end

if isempty(dd)
	c = computer;

	if c(1:2) == 'PC'
   		% Try %UserProfile% first. This is defined by NT
   		dd = getenv('UserProfile');
   		if isempty(dd)
      	% Try the windows registry next. Win95/98 uses this
      	% if User Profiles are turned on (you can check this
      	% in the "Passwords" control panel).
      		dd = get_profile_dir;
      		if isempty(dd)
         	% This must be Win95/98 with user profiles off.
         		dd = getenv('windir');
      		end
   		end
   
   	dd = fullfile(dd, 'Application Data', 'MathWorks', 'MATLAB', 'R14', '');
   
	else % Unix
   		dd = fullfile(getenv('HOME'), '.matlab', 'R14', '');
	end
end

if(createIfNecessary)
   ensure_directory(dd);
end
dd_out = dd;

function ensure_directory(dirname)
if ~exist(dirname, 'dir')
   [parent, dir, ext] = fileparts(dirname);
   dir = [dir ext];
   ensure_directory(parent);
   mkdir(parent, dir);
end

 
 function profileDir = get_profile_dir
 le = lasterr;
 try,
    profileDir = winqueryreg('HKEY_CURRENT_USER',...
       'Software\Microsoft\Windows\CurrentVersion\ProfileReconciliation',...
       'ProfileDirectory');
 catch,
    lasterr(le);
    profileDir = '';
 end

