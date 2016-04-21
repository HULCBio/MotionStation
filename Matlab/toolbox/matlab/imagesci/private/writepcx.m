function writepcx(X,map,fname)
%WRITEPCX Write a PCX file to disk.
%   WRITEPCX(X,MAP,FILENAME) writes the indexed image X,MAP
%   to the file specified by the string FILENAME.

%   Drea Thomas, 7-20-93.
%   Revised Steven L. Eddins, June 1996.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:01:39 $

switch (class(X))
case {'logical', 'uint8', 'double', 'single'}
otherwise
    error('MATLAB:writepcx:badImageClass', ...
          'X must be double, uint8, or logical');
end

if ((ndims(X) == 3) && (size(X,3) == 3))
    error('MATLAB:writepcx:rgbNotSupported', ...
          'RGB output not supported for PCX files');
end
if (ndims(X) > 2)
    error('MATLAB:writepcx:tooManyDims', ...
          'Input array must be 2-D');
end

if (isempty(map))
    error('MATLAB:writepcx:missingColormap', ...
          'Colormap not specified');
end

m = size(map, 1);
if (m<256)
    map=[map;zeros(256-m,3)];
elseif (m>256)
    error('MATLAB:writepcx:tooManyColormapEntries', ...
          'PCX colormaps must have 256 or fewer entries');
end;

fid=fopen(fname,'wb','l');
if (fid==-1)
    error('MATLAB:writepcx:fileOpen', ...
          ['Error opening ',fname,' for output.']);
end;

fwrite(fid,10,'uint8'); % PCX ID
fwrite(fid,5,'uint8');  % PCX Version #

nEncoding=1;
fwrite(fid,nEncoding,'uint8');
nBits=8;
fwrite(fid,nBits,'uint8');
nXmin=0;
fwrite(fid,nXmin,'int16');
nYmin=0;
fwrite(fid,nYmin,'int16');
[nVres,nHres]=size(X);
nXmax=nHres-1;
fwrite(fid,nXmax,'int16');
nYmax=nVres-1;
fwrite(fid,nYmax,'int16');
fwrite(fid,nHres,'int16');
fwrite(fid,nVres,'int16');
nHPalette=zeros(1,48);
fwrite(fid,nHPalette,'uint8');
nReserved=0;
fwrite(fid,nReserved,'uint8');
nPlanes=1;
fwrite(fid,nPlanes,'uint8');
nBytesPerLine=nHres;
fwrite(fid,nBytesPerLine,'int16');
nHPaletteInf=1;
fwrite(fid,nHPaletteInf,'int16');
nVidX=0;
fwrite(fid,nVidX,'int16');
nVidY=0;
fwrite(fid,nVidY,'int16');
nBlanks=zeros(1,54);
fwrite(fid,nBlanks,'uint8');
fclose(fid);

if isa(X,'logical')
    X = uint8(X);
elseif ~isa(X,'uint8')
    X = uint8(X-1);
end
pcxrle(fname, X');

fid = fopen(fname, 'ab', 'l');

fwrite(fid,12,'uint8');
map=(map').*255;
map=round(map(:));
fwrite(fid,map,'uint8');
fclose(fid);
