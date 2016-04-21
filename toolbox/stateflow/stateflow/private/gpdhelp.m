function gpdhelp( topic, help_file_name )
% GPDHELP( TOPIC , HELP_FILE_NAME )

%   E.Mehran Mestchian
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.12.2.2 $  $Date: 2004/04/15 00:58:14 $

fid=fopen(help_file_name,'r');
if fid<3, return; end

%%% fast method using regexp

H = fread(fid,'*char')';
fclose(fid);
[s,f]=regexp(H,['\$',upper(topic),'\$'], 'once');
if isempty(f), return; end
s=f+1;
f=regexp(H(s:length(H)),'\$', 'once');
if isempty(f), return; end
disp(H(s:s+f-2));
return

%%% slow method, not using regexp!

TOPIC = ['$',upper(topic),'$'];

while 1
	line = fgetl(fid);
	if ~isstr(line), break; end
	if strcmp(line,TOPIC)
		while 2
			line = fgetl(fid);
			if ~isstr(line), break; end
			if ~isempty(line)
				if line(1)=='$'
					break;
				end
			end
			disp(line)
		end % loop 2
		break;
	end
end % loop 1
fclose(fid);
