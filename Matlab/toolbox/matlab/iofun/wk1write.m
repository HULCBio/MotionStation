function wk1write(filename, m, r, c)
%WK1WRITE Write spreadsheet (WK1) file.
%   WK1WRITE('FILENAME',M) writes matrix M into a Lotus WK1 spreadsheet
%   file with the name.  '.wk1' is appended to the filename if no
%   extension is given.
%
%   WK1WRITE('FILENAME',M,R,C) writes matrix M into a Lotus WK1 spreadsheet
%   file, starting at offset row R, and column C in the file.  R and C
%   are zero-based so that R=C=0 is the first cell in the spreadsheet.
%
%   See also WK1READ, DLMWRITE, DLMREAD, CSVWRITE, CSVREAD.

%   Brian M. Bourgault 10/22/93
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.16 $  $Date: 2002/06/17 13:26:53 $
%
% include WK1 constants
%
wk1const

%
% test for proper filename
%
if ~isstr(filename),
    error('FILENAME must be a string.');
end;

if nargin < 2
    error('Requires at least 2 input arguments.');
end

%
% open the file Lotus uses Little Endian Format ONLY
%
if ~isempty(filename) & all(filename~='.'),
    filename = [filename '.wk1'];
end
fid = fopen(filename,'wb', 'l');

if fid == (-1)
    error(['Could not open file ' filename '.']);
end
%
% check for row,col offsets
%
if nargin < 3
    r = 0;
end
if nargin < 4
    c = 0;
end

%
% Lotus WK1 BOF
%
fwrite(fid, LOTWK1BOFSTR,'uchar');

%
% Lotus WK1 dimensions size of matrix
[br,bc] = size(m);
LOTrng = [0 0 bc br];
wk1wrec(fid, LOTDIMENSIONS, 0);
fwrite(fid, LOTrng, 'ushort');

%
% Lotus WK1 cpi
%
wk1wrec(fid, LOTCPI, 0);
fwrite(fid, [0 0 0 0 0 0], 'uchar');

%
% Lotus WK1 calcount
%
wk1wrec(fid, LOTCALCCNT, 0);
fwrite(fid, 0, 'uchar');

% Lotus WK1 calcmode
wk1wrec(fid, LOTCALCMOD, 0);
fwrite(fid, -1, 'char');

%
% Lotus WK1 calorder
%
wk1wrec(fid, LOTCALCORD, 0);
fwrite(fid, 0, 'char');

%
% Lotus WK1 split
%
wk1wrec(fid, LOTSPLTWM, 0);
fwrite(fid, 0, 'char');

%
% Lotus WK1 sync
%
wk1wrec(fid, LOTSPLTWS, 0);
fwrite(fid, 0, 'char');

%
% Lotus WK1 cursor12
%
wk1wrec(fid, LOTCURSORW12, 0);
fwrite(fid, 1, 'char');

%
% Lotus WK1 window1, for now but needs work !!!
%
deffmt = 113;
wk1wrec(fid, LOTWINDOW1, 0);
fwrite(fid, [0 0], 'ushort');
fwrite(fid, deffmt, 'char');    
fwrite(fid, 0, 'char'); 
fwrite(fid, 10, 'ushort');
fwrite(fid, [bc br], 'ushort');
fwrite(fid, [0 0 0 0], 'ushort');
fwrite(fid, [0 0 0 0], 'ushort');
fwrite(fid, [72 0], 'ushort');

%
% Lotus WK1 hidcol
%
x = 1:LOTHIDCOL(2);
buf = ones(size(x)) * 0;
wk1wrec(fid, LOTHIDCOL, 0);
fwrite(fid, buf, 'char');

%
% Lotus WK1 margins
%
buf = [4 76 66 2 2];
wk1wrec(fid, LOTMARGINS, 0);
fwrite(fid, buf, 'ushort');

%
% Lotus WK1 labelfmt
%
wk1wrec(fid, LOTLABELFMT, 0);
fwrite(fid, '''', 'char');

%
% start dumping the array, for now number format float
%
for i = 1:br
    for j = 1:bc
    wk1wrec(fid, LOTNUMBER, 0);
    fwrite(fid, deffmt, 'char');    
    fwrite(fid, [ c+j-1 r+i-1 ], 'ushort');
    fwrite(fid, m(i,j), 'double');
    end
end


%
% Lotus WK1 EOF
%
fwrite(fid, LOTEOFSTR,'uchar');

% close files
fclose(fid);
