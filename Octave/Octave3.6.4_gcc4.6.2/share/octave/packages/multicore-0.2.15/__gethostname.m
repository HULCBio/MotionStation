function hostnameOut = gethostname
%GETHOSTNAME  Get host name.
%		HOSTNAME = GETHOSTNAME returns the name of the computer that MATLAB 
%		is running on. Function should work for both Linux and Windows.
%
%		Markus Buehren
%		Last modified 13.11.2007
%
%		See also GETUSERNAME.

persistent hostname

if isempty(hostname)
	if ispc
		[s, hostname] = system('hostname'); %#ok
	else
		[s, hostname] = system('uname -n'); %#ok
	end
	hostname = hostname(1:end-1);
end

hostnameOut = hostname;
