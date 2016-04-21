function [X,map] = readpcx(filename)
%READPCX Read image data from a PCX file.
%   [X,MAP] = READPCX(FILENAME) reads image data from a PCX file.
%   X is a uint8 array that is 2-D for indexed or grayscale image
%   data, and it is M-by-N-by-3 for truecolor image data. MAP is
%   normally an M-by-3 MATLAB colormap, but it may be empty if
%   the PCX file does not contain a colormap.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:49 $

%   Murray and vanRyper, Encyclopedia of Graphics File Formats,
%   2nd ed., O'Reilly, 1996.

info = impcxinfo(filename);

fid = fopen(filename,'r','ieee-le');
status = fseek(fid,128,'bof');
if status==-1
  fclose(fid);
  error('MATLAB:readpcx:dataOffset', ...
        'Error reading PCX data.  Invalid data offset.');
end
buffer = fread(fid,'*uint8');
fclose(fid);

scanLineLength = info.NumColorPlanes * info.BytesPerLine;

[X, endIndex] = pcxdrle(buffer, info.Height, scanLineLength);
X = X';

map = [];
lookForVGAPalette = 1;
switch info.NumColorPlanes
case 1
    switch info.BitsPerPixelPerPlane
    case 1
        XX = X;
        X = repmat(logical(false), size(XX) .* [1 8]);
        for k = 1:8
            X(:,k:8:end) = bitslice(XX, 8-k+1, 8-k+1);
        end
        map = [0 0 0; 1 1 1];     % In case a palette isn't found later.
        
    case 8
        % Nothing to do
        
    otherwise
        error('MATLAB:readpcx:badBitDepthColorPlaneCombo', ...
              'Unsupported combination of "BitDepth" and "NumColorPlanes"');
    end
    
case 3
    switch info.BitsPerPixelPerPlane
    case 1
        error('MATLAB:readpcx:badBitDepthColorPlaneCombo', ...
              'PCX files with NumColorPlanes=3 and BitDepth=1 are not supported');
        
    case 8
        X = reshape(X, [size(X,1) size(X,2)/3 3]);
        lookForVGAPalette = 1;
        
    otherwise
        error('MATLAB:readpcx:badBitDepthColorPlaneCombo', ...
              'Unsupported combination of "BitDepth" and "NumColorPlanes"');
    end

case 4

    % When NumColorPlanes is 4, BitDepth must be 1.
    if (info.BitsPerPixelPerPlane ~= 1)
        msg = sprintf(['Invalid combination of "BitDepth" (%d) and' ...
                       ' "NumColorPlanes" (%d).'], ...
                      info.BitsPerPixelPerPlane, info.NumColorPlanes);
        error('MATLAB:readpcx:badBitDepthColorPlaneCombo', '%s', ...
              msg);
    end
    
    % Get the individual samples from the packed pixels.
    
    tmp = X;
    X = repmat(uint8(0), size(tmp) .* [1 8]);
    
    for k = 1:8
        X(:,k:8:end) = bitslice(tmp, 8-k+1, 8-k+1);
    end

    % The reconstituted array groups the samples together with all of the
    % samples from one scanline in the same row (rrr...ggg...bbb...iii...).
    % Separate the "color" planes.
    
    tmp = reshape(X, [info.Height, (2 * scanLineLength), 4]);
    
    % In this mode, the values in the "color" planes correspond to the
    % four bits of the indices into the colormap.  That is, the first
    % sample is the least-significant bit of the index, and the fourth
    % sample is the most-significant bit.
    
    X = double(tmp(:,:,1)) + double(bitshift(tmp(:,:,2), 1));
    X = X + double(bitshift(tmp(:,:,3), 2));
    X = X + double(bitshift(tmp(:,:,4), 3));
    X = uint8(X);
    
    % Remove any scanline padding.
    X = X(1:info.Height, 1:info.Width);
    
    % Get the colormap.
    
    lookForVGAPalette = 0;
    map = info.EGAPalette;
    
    if (~isempty(map))
        map = reshape(map, [3 16])'/255;
    end
    
otherwise
    error('MATLAB:readpcx:badNumPlanes', ...
          'Unrecognized value for NumColorPlanes');
    
end
    
if (info.Width ~= size(X,2))
    X = X(:,1:info.Width,:);
end

if (lookForVGAPalette)
    remainder = length(buffer) - endIndex;
    if (((remainder == 769) && (buffer(endIndex+1) == 12)) || ...
                (remainder == 768))
        % For "real" PCX files, remainder should be 769 if there's
        % a colormap. However, pcxwrite in IPT v1 failed to write the
        % 0Cx value in the byte before colormap.  For those
        % files, remainder will be 768 and there's no 0Cx code.  -SLE
        map = buffer(end-767:end);
        map = double(reshape(map,3,256)')/255;
    end
end
