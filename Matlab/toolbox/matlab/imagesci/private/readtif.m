function [X,map] = readtif(filename, varargin)
%READTIF Read an image from a TIFF file.
%   [X,MAP] = READTIF(FILENAME) reads the first image from the
%   TIFF file specified by the string variable FILENAME.  X will
%   be a 2-D uint8 array if the specified data set contains an
%   8-bit image.  It will be an M-by-N-by-3 uint8 array if the
%   specified data set contains a 24-bit image.  MAP contains the
%   colormap if present; otherwise it is empty. 
%
%   [X,MAP] = READTIF(FILENAME, N, ...) reads the Nth image from the
%   file.
%
%   [X,MAP] = READTIF(FILENAME, 'Index', N, ...) reads the Nth image
%   from the file.
%
%   [X,MAP] = READTIF(FILENAME, 'PixelRegion', {ROWS, COLS}, ...)
%   reads a region of pixels from a tiled TIFF image.  ROWS and COLS
%   are two or three element vectors, where the first value is the start
%   location, and the last value is the ending location.  In the three
%   value syntax, the second value is the increment.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/04/01 16:12:29 $

args = parse_args(varargin{:});

if (isempty(args.pixelregion))
    
    [X, map, details] = rtifc(filename, args.index);
    
    % Trim extra padding from tiled TIFF, if necessary.
    if ((size(X, 1) ~= details.ImageWidth) || ...
        (size(X, 2) ~= details.ImageHeight))
        
        X = X(1:details.ImageHeight, 1:details.ImageWidth, :);
        
    end
    
else
    
    region = process_region(args.pixelregion);
    [X, map, details] = rtifc(filename, args.index, region);
    X = trim_region(X, region, details);
    
end

map = double(map)/65535;

if (details.Photo == 8)
    % TIFF image is in CIELAB format.  Issue a warning that we're
    % converting the data to ICCLAB format, and correct the a* and b*
    % values.
    
    % First, though, check to make sure we have the expected number of
    % samples per pixel.
    if (size(X,3) ~= 1) && (size(X,3) ~= 3)
        eid = 'MATLAB:imread:unexpectedCIELabSamplesPerPixel';
        msg = 'Unexpected number of samples per pixel for CIELab image.';
        error(eid,'%s',msg);
    end
    
    wid = 'MATLAB:imread:CielabConversion';
    msg = 'Converting CIELab-encoded TIFF image to ICCLab encoding.';
    warning(wid,'%s',msg);
    
    X = cielab2icclab(X);
end



function args = parse_args(varargin)
%PARSE_ARGS  Convert input arguments to structure of arguments.

args.index = 1;
args.pixelregion = [];

params = {'index',
          'pixelregion'};

p = 1;
while (p <= nargin)
   
    if (isnumeric(varargin{p}))
        
        args.index = varargin{p};
        p = p + 1;
        
    elseif (ischar(varargin{p}))
        
        idx = strmatch(lower(varargin{p}), params);
        
        if (isempty(idx))
            error('MATLAB:readtif:unknownParam', ...
                  'Unknown parameter ''%s''.', varargin{p})
        elseif (numel(idx) > 1)
            error('MATLAB:readtif:ambiguousParam', ...
                  'Ambiguous parameter ''%s''.', varargin{p})
        end
        
        if (p == nargin)
            error('MATLAB:readtif:missingValue', ...
                  'Missing value for parameter ''%s''.', varargin{p})
        end
        
        args.(params{idx}) = varargin{p + 1};
        p = p + 2;
        
    else
        
        error('MATLAB:readtif:paramType', ...
              'Parameter names must be character arrays.')
        
    end
            
end



function region_struct = process_region(region_cell)
%PROCESS_PIXELREGION  Convert a cells of pixel region info to a struct.

region_struct = struct([]);

if (numel(region_cell) ~= 2)
    error('MATLAB:readtif:pixelRegionCell', ...
          'PixelRegion must be a two element cell array.')
end

for p = 1:numel(region_cell)
    
    if (numel(region_cell{p}) == 2)
        
        start = max(0, region_cell{p}(1) - 1);
        incr = 1;
        stop = region_cell{p}(2) - 1;
        
    else
        
        start = max(0, region_cell{p}(1) - 1);
        incr = region_cell{p}(2);
        stop = region_cell{p}(3) - 1;
       
    end
        
    if (start > stop)
        error('MATLAB:readtif:badPixelRegionStartStop', ...
              'Stop value must be greater than start value.')
    end
    
    region_struct(p).start = start;
    region_struct(p).incr = incr;
    region_struct(p).stop = stop;

end



function out = trim_region(in, region, details)
%TRIM_REGION  Remove extra pixels from a requested region.

% The input array will be composed of all of the pixels in the tiles
% that cover the requested region.  The upper left-hand corner of this
% array is the corner of the upper left-hand tile.

% Trim region to fit within actual image.
region(1).stop = min(region(1).stop, details.ImageHeight - 1);
region(2).stop = min(region(2).stop, details.ImageWidth - 1);

% Find U-L corner of region in input array.
if (isempty(details.TileHeight) || isempty(details.TileWidth))
    
    % Nontiled images always start at (1,1)
    out = in((region(1).start + 1):region(1).incr:(region(1).stop + 1), ...
             (region(2).start + 1):region(2).incr:(region(2).stop + 1), ...
             :);
    return;
    
else
    
    % Register beginning of region with U-L tile.
    offsetRow = mod(region(1).start, details.TileHeight) + 1;
    offsetCol = mod(region(2).start, details.TileWidth) + 1;
    
end

numRows = region(1).stop - region(1).start;
numCols = region(2).stop - region(2).start;

incrRow = region(1).incr;
incrCol = region(2).incr;

out = in(offsetRow:incrRow:(offsetRow + numRows), ...
         offsetCol:incrCol:(offsetCol + numCols), ...
         :);
