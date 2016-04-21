function [X, map, mask] = readcur(filename, index)
%READCUR Read cursor from a Windows CUR file
%   [X,MAP] = READCUR(FILENAME) reads image data from a CUR file
%   containing one or more Microsoft Windows cursor resources.  X
%   is a 2-D uint8 array.  MAP is an M-by-3 MATLAB colormap.  If
%   FILENAME contains more than one cursor resource, the first will
%   be read.
%
%   [X,MAP] = READCUR(FILENAME,INDEX) reads the cursor in position
%   INDEX from FILENAME, which contains multiple cursors.
%
%   [X,MAP,MASK] = READCUR(FILENAME,...) returns the transperency mask
%   for the given image from FILENAME.
%
%   Note: By default Microsoft Windows cursor resources are 32-by-32
%   pixels.  MATLAB requires that pointers be 16-by-16.  Images read
%   with READCUR will likely need to be scaled.  The IMRESIZE function
%   in the Image Processing Toolbox may be helpful.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:44 $
%   $ Revision $  $ Date $

if (nargin < 2)
    index = 1;
end

if (~ischar(filename))
    error('MATLAB:readcur:badFilename', ...
          'Requires a string filename as an argument.');
end;

if (isempty(findstr(filename,'.')))
    filename=[filename,'.cur'];
end;

[info, msg] = imfinfo(filename, 'cur');

if (isempty(info))
    error('MATLAB:readcur:noFileInfo', '%s', msg)
end

if (ischar(index))
    msg = sprintf('Unknown option: %s', index);
    error('MATLAB:readcur:badIndex', '%s', msg);
end

if (index < 1)
    error('MATLAB:readcur:badIndex', ...
          'Cursor index is 1-based not 0-based.')
end	

if (index > length(info))
    msg = sprintf('Cannot read cursor number %d since %.900s only contains %d cursors.\n', index, filename, length(info));
    error('MATLAB:readcur:indexOutOfRange', '%s', msg)
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
