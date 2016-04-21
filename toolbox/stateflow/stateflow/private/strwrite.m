function result = strwrite( string, filename, flags )
%STRWRITE   Write a string matrix into a given filename
%
%           COUNT = STRWRITE( string, filename ) returns the number of lines
%           successfully written.
%
%           COUNT = STRWRITE( string, filename, flag) applies the given flags
%           when opening filename. Otherwise 'w' flag is used (see also FOPEN).

%   E.Mehran Mestchian
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.12.2.2 $  $Date: 2004/04/15 01:00:51 $

host = computer;

if host(1:2)=='PC'
	line = '%s\r\n';
	offset=2;
else
	line = '%s\n';
	offset=1;
end

if nargin<3
	flags='w';
end

fid = fopen(filename,flags);
if fid<0, error(sprintf('could not create %s.',filename)); end
l=strlen(string);
for i=1:length(l)
	count = fprintf(fid,line,char(i,1:l(i)));
	if count ~= l(i)+offset
		fclose(fid);
		error(sprintf('writing to %s failed on line %s.',filename,sf_scalar2str(i)));
	end
end
fclose(fid);
result=length(l);
