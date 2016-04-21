function [X, map, mask] = readico(filename, index)
%READICO Read icon from a Windows ICO file
%   [X,MAP] = READICO(FILENAME) reads image data from an ICO file
%   containing one or more Microsoft Windows icon resources.  X is
%   a 2-D uint8 array.  MAP is an M-by-3 MATLAB colormap.  If
%   FILENAME contains more than one icon resource, the first will
%   be read.
%
%   [X,MAP] = READICO(FILENAME,INDEX) reads the icon in position INDEX
%   from FILENAME, which contains multiple icons.
%
%   [X,MAP,MASK] = READICO(FILENAME,...) returns the transperency mask
%   for the given image from FILENAME.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:47 $
%   $ Revision $  $ Date $

if (nargin < 2)
    index = 1;
end

if (~ischar(filename))
    error('MATLAB:readico:badFilename', ...
          'Requires a string filename as an argument.');
end;

if (isempty(findstr(filename,'.')))
    filename=[filename,'.ico'];
end;

[info, msg] = imfinfo(filename, 'ico');

if (isempty(info))
    error('MATLAB:readico:noFileInfo', '%s', msg)
end

if (ischar(index))
    msg = sprintf('Unknown option: %s', index);
    error('MATLAB:readico:badIndex', '%s', msg);
end

if (index < 1)
    error('MATLAB:readico:badIndex', ...
          'Icon index is 1-based not 0-based.')
end	

if (index > length(info))
    msg = sprintf('Cannot read icon number %d since %.900s only contains %d icons.\n', index, filename, length(info));
    error('MATLAB:readico:indexOutOfRange', '%s', msg)
end

% Read the XOR data and its colormap
X = readbmpdata(info(index));

map = info(index).Colormap;

maskinfo = info(index);
maskinfo.BitDepth = 1;

% Caluculate the offset of the AND mask.
% Bitmap scanlines are aligned on 4 byte boundaries
imsize = maskinfo.Height * (32 * ceil(maskinfo.Width / 32))/8;
maskinfo.ImageDataOffset = maskinfo.ResourceDataOffset + ...
    maskinfo.ResourceSize - imsize;

mask = readbmpdata(maskinfo);
