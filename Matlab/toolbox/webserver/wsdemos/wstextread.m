function cas = wstextread(sFileName, cDlm)
%WSTEXTREAD puts a delimited file in a cell array of strings.
%   CAS = WSTEXTREAD(SFILENAME, CDLM) returns the contents of
%   file SFILENAME delimited with the delimiter character CDLM
%   in CAS, a cell array of strings.
%   CAS = WSTEXTREAD(SFILENAME) uses the tab character as the 
%   default delimiter.
%

%   Author(s): M. Greenstein, 05-27-98
%   Copyright 1998-2001 The MathWorks, Inc.
%   $Revision: 1.6 $   $Date: 2001/04/25 18:49:32 $

% Initializations
cas = {};
cD = char(9);

% Argument checking
if (nargin < 1)
    error('Insufficient number of arguments.');
end
if (~ischar(sFileName))
    error('The filename argument is not a character array.');
end
if (nargin > 1)
   if (~ischar(cDlm))
       error('The delimiter argument is not a character.');
   end
   cD = cDlm(1);
end

% Attempt to open the input file.
fid = fopen(sFileName, 'rt');
if (-1 == fid)
    error(['File open failure for: ' sFileName '.']);
end

% Read through the file.
i = 1;
while (i)
	line = fgetl(fid);
	if (isnumeric(line)), break; end
	j = 1;
	while (j)
		[s, line] = strtok(line, cD);
		if (~length(s)), break; end
		cas{i, j} = s;
        j = j + 1;
	end
	i = i + 1;
end

fclose(fid);

