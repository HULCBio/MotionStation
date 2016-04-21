function writebmp(X,map,filename)
%WRITEBMP Write a BMP (Microsoft Windows Bitmap) file to disk.
%   WRITEBMP(X,MAP,FILENAME) writes the indexed image X,MAP
%   to the file specified by the string FILENAME.  If X is Logical, 
%   the data is written as a 1-bit BMP.  
%
%   WRITEBMP(RGB,[],FILENAME) writes the truecolor image
%   represented by the M-by-N-by-3 array RGB.

%   Mounil Patel 3/10/94
%   Revised Steven L. Eddins August 1996
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:01:35 $

if (~isa(X,'logical') && ~isa(X,'uint8') && ~isa(X,'single') && ~isa(X,'double'))
    error('MATLAB:writebmp:unsupportedImageClass', ...
          'Class of X must be logical, uint8, single, or double.');
end

numdims = ndims(X);
numcomps = size(X,3);

%Calculate image bit depth
if islogical(X)
  biBitCount=1;
else
  biBitCount=8*numcomps;
end

if ((numdims > 2) && ((numdims ~= 3) || (size(X,3) ~= 3)))
    error('MATLAB:writebmp:badImageDimensions', ...
          'Invalid dimensions for X.');
end

if ((numcomps == 1) && (isempty(map)))
  if biBitCount==1
    n = 2;
    map = gray(n);
  else
    n = 256;
    map = gray(n);
    if ((isa(X,'double')) || (isa(X,'single')))
      X = uint8(round(X*(n-1)));    
    end
  end
end

if ((biBitCount==1) && (size(map,1) ~= 2))
    error('MATLAB:writebmp:wrongNumberOfColormapEntries', ...
          '1-bit BMP colormaps must have 2 entries.');
end

if ((numcomps == 1) && (size(map,1) > 256))
    error('MATLAB:writebmp:wrongNumberOfColormapEntries', ...
          'BMP colormaps must have 256 or fewer entries.');
end

if ((numcomps == 1) && (size(map,2) ~= 3))
    error('MATLAB:writebmp:wrongNumberOfColormapEntries', ...
          'Invalid colormap size.');
end

fid=fopen(filename,'wb','l');
if (fid==-1)
    error('MATLAB:writebmp:fileOpen', ...
          ['Error opening ',filename,' for output.']);
end;
    
biHeight = size(X,1);
biWidth = size(X,2);

if ((isa(X,'double')) || (isa(X,'single'))) && (biBitCount~=1)
    if (numcomps == 3)
        X = uint8(round(255*X));
    else
        X = uint8(X-1);
    end
end

% Squeeze 3rd dimension into second
if (numcomps == 3)
    X = X(:,:,[3 2 1]);
    X = permute(X, [1 3 2]);
    X = reshape(X, [size(X,1) size(X,2)*size(X,3)]);
end

width = size(X,2);
if biBitCount==1
  %Do calculations in bits
  tmp = rem(width,32);
  if (tmp > 0)
    padding = 32 - tmp;
    X = cat(2, X, repmat(logical(uint8(0)), [size(X,1) padding]));
  else
    padding = 0;
  end
else  
  tmp = rem(width,4);
  if (tmp > 0)
    padding = 4 - tmp;
    X = cat(2, X, repmat(uint8(0), [size(X,1) padding]));
  else
    padding = 0;
  end
end
% Rotate X to compensate for BMP scanline orientation.
% In BMP files, the bottom scanline is written first.
X = rot90(X, -1);

fwrite(fid,[66;77],'uint8');

% What will be the physical file size?  First term: image data,
% with width padded to be multiple of 4.  Second term: length of
% bitmap header.  Third term: length of bitmap information
% header.  Third term: length of color palette.
if (numcomps == 1)
  if biBitCount==1
    bfSize = biHeight*(width+padding)/8 + 14 + 40 + 2*4;
  else
    bfSize = biHeight*(width+padding) + 14 + 40 + 256*4;
  end
else
    % No palette written for RGB images
    bfSize = biHeight*(width+padding) + 14 + 40;
end
fwrite(fid,bfSize,'uint32');
bfReserved1=0;
fwrite(fid,bfReserved1,'uint16');
bfReserved2=0;
fwrite(fid,bfReserved2,'uint16');
if (numcomps == 1)
  if biBitCount==1
    %Always 2 colors in 1-bit bmp colormap
    bfOffBytes=54+2*4;
  else
    bfOffBytes=1078;
  end  
else
    % No palette written for RGB images
    bfOffBytes = 54;
end
fwrite(fid,bfOffBytes,'uint32');
biSize=40;
fwrite(fid,biSize,'uint32');

fwrite(fid,biWidth,'uint32');
fwrite(fid,biHeight,'uint32');
biPlanes=1;
fwrite(fid,biPlanes,'uint16');
fwrite(fid,biBitCount,'uint16');
biCompression=0;
fwrite(fid,biCompression,'uint32');
if biBitCount==1
  biSizeImage=biHeight*(width+padding)/8;
else
  biSizeImage=biHeight*(width+padding);
end
fwrite(fid,biSizeImage,'uint32');
biXPels=0;
fwrite(fid,biXPels,'uint32');
biYPels=0;
fwrite(fid,biYPels,'uint32');
if (numcomps == 1)
  if biBitCount==1
    biClrUsed=2;
  else
    biClrUsed=256;
  end
else
    % Not relevant for RGB images.
    biClrUsed = 0;
end
fwrite(fid,biClrUsed,'uint32');
biClrImportant=0;
fwrite(fid,biClrImportant,'uint32');

if (numcomps == 1)
  if biBitCount==1
    map=[fliplr(round(map*255)),zeros(2,1)]';
  else
    map = [map; zeros(256 - size(map,1), 3)];
    map=[fliplr(round(map*255)),zeros(256,1)]';
  end
  fwrite(fid,map(:),'uint8');
end

if biBitCount==1
  %Repoen file with big endian byte ordering 
  fclose(fid);
  fid=fopen(filename,'ab+','b');
  if (fid==-1)
    error('MATLAB:writebmp:fileOpen', ...
          ['Error opening ',filename,' for output.']);
  end;
  fseek(fid,0,'eof');
  fwrite(fid,X,'ubit1');
else
  fwrite(fid,X,'uint8');
end

fclose(fid);

