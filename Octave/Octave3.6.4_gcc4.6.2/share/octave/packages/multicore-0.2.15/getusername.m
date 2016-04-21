function usernameOut = getusername
%GETUSERNAME  Get user name.
%		USERNAME = GETUSERNAME returns the login name of the current MATLAB 
%		user. Function should work for both Linux and Windows.
%
%		Markus Buehren
%		Last modified 13.11.2007
%
%		See also GETHOSTNAME.

persistent username

if isempty(username)
	if ispc
		username = getenv('username');
	else
		[ignore, username] = system('whoami'); %#ok
		username = username(1:end-1);
	end
end

usernameOut = username;

