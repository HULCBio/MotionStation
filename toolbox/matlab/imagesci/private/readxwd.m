function [M,CM] = readxwd(fname)
%READXWD Read image data from an XWD file.
%   [X,MAP] = READPCX(FILENAME) reads image data from a PCX file.
%   X is a 2-D uint8 array.  MAP is an M-by-3 MATLAB-style
%   colormap.  XWDREAD can the following types of XWD files:
%    1-bit or 8-bit ZPixmaps
%    XYBitmaps
%    1-bit XYPixmaps
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:54 $

%   Reference:  Murray and vanRyper, Encyclopedia of Graphics
%   File Formats, 2nd ed, O'Reilly, 1996.

info = imxwdinfo(fname);

if (info.ByteOrder == 0)
    [fid, message] = fopen(fname, 'r', 'ieee-le');
elseif (info.ByteOrder == 1)
    [fid, message] = fopen(fname, 'r', 'ieee-be');
else
    error('MATLAB:readxwd:badByteOrder', ...
          'Unrecognized value in ByteOrder field');
end
if (fid == -1)
    error('MATLAB:readxwd:fileOpen', message);
end

% See if it is an XYPixmap (unsupported)
if (strcmp(info.PixmapFormat, 'XYPixmap') && (info.PixmapDepth ~= 1))
    message = sprintf('%d-bit XYpixmaps not supported', info.PixmapDepth);
    error('MATLAB:readxwd:badXYPixmap', message);
end

fseek(fid, info.HeaderSize, 'bof');
tmp = fread(fid,[6 info.NumColormapEntries],'uint16');
CM = [(tmp(2,:)+tmp(1,:)*65535)',tmp(3:5,:)'/65535];

% What storage format is the data in?
if (strcmp(info.PixmapFormat, 'ZPixmap') || ...
            strcmp(info.PixmapFormat, 'XYBitmap') || ...
            (strcmp(info.PixmapFormat, 'XYPixmap') && (info.PixmapDepth == 1)))
    % ZPixmap,  XYbitmap or XYpixmap depth 1
    % Size of pixels
    if (ismember(info.PixmapDepth, [1 8]))
        prec = 'uint8';
    else
        message = sprintf('%d-bit Zpixmaps not supported', info.PixmapDepth);
        error('MATLAB:readxwd:badZPixmap', message);
    end

    if (info.PixmapDepth == 8), % ZPixmap with depth 8
        pad = ceil(info.Width/info.BitmapPad*info.PixmapDepth) * ...
                info.BitmapPad/info.PixmapDepth - info.Width;
        M = uint8(fread(fid,[info.Width+pad info.Height], prec))';
    else      
        % ZBitmap XYPitmap or XYPixmap of depth 1
        M = fread(fid,[info.Width/8 info.Height],'uint8')';

        % Take apart bytes into 8 bits and store as a matrix of 1's and 0's
        [a,b]=size(M);
        P=logical(repmat(uint8(0), a, b*8));
        for i=7:-1:0,
            tmp=find(M/2^i >= 1);
            if ~isempty(tmp),
                M(tmp)=M(tmp)-2^i;
                P(tmp+ceil(tmp/a)*(7*a)+(-i)*a+a*(2*i-7) * ...
                        (~info.BitmapBitOrder)) = 1;
            end
        end
        CM=[0 1 1 1;1 0 0 0];
        M=P;
    end
    
else
    message = sprintf('%d-bit %s not supported', info.PixmapDepth, ...
            info.PixmapFormat);
    error('MATLAB:readxwd:badFormat', message);
end

CM=CM(:,2:4);

fclose(fid);
