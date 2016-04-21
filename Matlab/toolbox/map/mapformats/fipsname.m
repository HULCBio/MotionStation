function struct = fipsname(filename)
% FIPSNAME Read the name file used to index the TIGER thinned boundary files.
%
% S = FIPSNAME opens a file selection window to pick a file, reads the
% Federal Information Processing Standard codes, and returns them in a
% structure.
%
% S = FIPSNAME(FILENAME) reads the specified file.
%
% See also: TIGERP, TIGERMIF

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $
%  Written by:  W. Stumpf


if nargin == 0
	[filename, path] = uigetfile('*', 'Please find the FIPS name file');
	if filename == 0 ; return; end
	fid = fopen([path filename],'r');
elseif nargin == 1
	fid = fopen(filename,'r');
	if fid == -1
	   [filename, path] = uigetfile('*', 'Please find the FIPS name file');
		if filename == 0 ; return; end
		fid = fopen([path filename],'r');
	end
else
	error('Incorrect number of arguments')
end

%
% Read a line at a time, and parse into number and string.
%
%

i=0;
while 1
    line = fgetl(fid);
    if ~isstr(line), break, end
	if length(line) >1
	    i = i+1;
        [id,count,errmsg,nextindx] = sscanf(line,'%d',1);
		strname = line(nextindx:length(line));
		strname = leadblnk(deblank(strname));
		struct(i).name = strname;
		struct(i).id = id;
	end
end

fclose(fid);

