function imwrite(varargin)
%IMWRITE Write image to graphics file.
%   IMWRITE(A,FILENAME,FMT) writes the image A to the file specified by
%   FILENAME in the format specified by FMT.
%
%   A can be an M-by-N (grayscale image) or M-by-N-by-3 (color image)
%   array.  A cannot be an empty array.  If the format specified is TIFF,
%   IMWRITE can also accept an M-by-N-by-4 array containing color data
%   that uses the CMYK color space.
%
%   FILENAME is a string that specifies the name of the file.
%
%   FMT is a string specifying the format of the file.  See the reference
%   page, or the output of the IMFORMATS function, for a list of
%   supported formats.
%
%   IMWRITE(X,MAP,FILENAME,FMT) writes the indexed image in X and its
%   associated colormap MAP to FILENAME in the format specified by FMT.
%   If X is of class uint8 or uint16, IMWRITE writes the actual values in 
%   the array to the file.  If X is of class double, IMWRITE offsets the
%   values in the array before writing, using uint8(X-1).  MAP must be a
%   valid MATLAB colormap.  Note that most image file formats do not
%   support colormaps with more than 256 entries.
%
%   IMWRITE(...,FILENAME) writes the image to FILENAME, inferring the
%   format to use from the filename's extension. The extension must be
%   one of the legal values for FMT. 
%
%   IMWRITE(...,PARAM1,VAL1,PARAM2,VAL2,...) specifies parameters that
%   control various characteristics of the output file. Parameters are
%   currently supported for HDF, JPEG, TIFF, PNG, PBM, PGM, and PPM files.
%
%   Class Support
%   -------------
%   The input array A can be of class logical, uint8, uint16, or double.
%   Indexed images (X) can be of class uint8, uint16, or double; the
%   associated colormap, MAP, must be double.
%
%   The class of the image written to the file depends on the format
%   specified.  For most formats, if the input array is of class uint8,
%   IMWRITE outputs the data as 8-bit values.  If the input array is of
%   class uint16 and the format supports 16-bit data (JPEG, PNG, and
%   TIFF), IMWRITE outputs the data as 16-bit values.  If the format does
%   not support 16-bit values, IMWRITE issues an error.  Several formats,
%   such as JPEG and PNG, support a parameter that lets you specify the
%   bit depth of the output data.
%
%   If the input array is of class double, and the image is a grayscale
%   or RGB color image, IMWRITE assumes the dynamic range is [0,1] and
%   automatically scales the data by 255 before writing it to the file as
%   8-bit values.
%
%   If the input array is of class double, and the image is an indexed
%   image, IMWRITE converts the indices to zero-based indices by
%   subtracting 1 from each element, and then writes the data as uint8.
%
%   If the input array is of class logical, IMWRITE assumes the data is a
%   binary image and writes it to the file with a bit depth of 1, if the
%   format allows it.  BMP, PNG, or TIFF formats accept binary images as
%   input arrays.
%
%   HDF-specific parameters
%   -----------------------
%   'Compression'  One of these strings: 'none' (the default), 
%                  'rle' (only valid for grayscale and indexed
%                  images), 'jpeg' (only valid for grayscale
%                  and RGB images)
%
%   'Quality'      A number between 0 and 100; parameter applies
%                  only if 'Compression' is 'jpeg'; higher
%                  numbers mean quality is better (less image
%                  degradation due to compression), but the
%                  resulting file size is larger 
%
%   'WriteMode'    One of these strings: 'overwrite' (the
%                  default) or 'append'
%
%   JPEG-specific parameters
%   ------------------------
%   'Quality'      A number between 0 and 100; higher numbers
%                  mean quality is better (less image degradation
%                  due to compression), but the resulting file
%                  size is larger
%
%   'Comment'      A column vector cell array of strings or a
%                  char matrix.  Each row of input is written out
%                  as a comment in the JPEG file.
%
%   'Mode'         Either 'lossy' (the default) or 'lossless'
%
%   'BitDepth'     A scalar value indicating desired bitdepth;
%                  for grayscale images this can be 8, 12, or 16;
%                  for truecolor images this can be 8 or 12
%
%   TIFF-specific parameters
%   ------------------------
%   'Colorspace'   One of these strings: 'rgb', 'cielab', or 
%                  'icclab'.  The default value is 'rgb'.  This 
%                  parameter is used only when the input array, 
%                  A, is M-by-N-by-3.  See the reference page
%                  for more details about creating L*a*b* TIFF 
%                  files.
%
%   'Compression'  One of these strings: 'none', 'packbits'
%                  (default for nonbinary images), 'ccitt'
%                  (default for binary images), 'fax3', 'fax4';
%                  'ccitt', 'fax3', and 'fax4' are valid for
%                  binary images only
%
%   'Description'  Any string; fills in the ImageDescription
%                  field returned by IMFINFO
%
%   'Resolution'   A two-element vector containing the
%                  XResolution and YResolution, or a scalar
%                  indicating both resolutions; the default value
%                  is 72
%
%   'WriteMode'    One of these strings: 'overwrite' (the
%                  default) or 'append'
%
%   PNG-specific parameters
%   -----------------------
%   'Author'       A string
%
%   'Description'  A string
%
%   'Copyright'    A string
%
%   'CreationTime' A string
%
%   'Software'     A string
%
%   'Disclaimer'   A string
%
%   'Warning'      A string
%
%   'Source'       A string
%
%   'Comment'      A string
%
%   'InterlaceType' Either 'none' or 'adam7'
%
%   'BitDepth'     A scalar value indicating desired bitdepth;
%                  for grayscale images this can be 1, 2, 4,
%                  8, or 16; for grayscale images with an
%                  alpha channel this can be 8 or 16; for
%                  indexed images this can be 1, 2, 4, or 8;
%                  for truecolor images with or without an
%                  alpha channel this can be 8 or 16
%
%   'Transparency' This value is used to indicate transparency
%                  information when no alpha channel is used.
%                  
%                  For indexed images: a Q-element vector in
%                    the range [0,1]; Q is no larger than the
%                    colormap length; each value indicates the
%                    transparency associated with the
%                    corresponding colormap entry
%                  For grayscale images: a scalar in the range
%                    [0,1]; the value indicates the grayscale
%                    color to be considered transparent
%                  For truecolor images: a 3-element vector in
%                    the range [0,1]; the value indicates the
%                    truecolor color to be considered
%                    transparent
%
%                  You cannot specify 'Transparency' and
%                  'Alpha' at the same time.
%
%   'Background'   The value specifies background color to be
%                  used when compositing transparent pixels.
%
%                  For indexed images: an integer in the range
%                    [1,P], where P is the colormap length
%                  For grayscale images: a scalar in the range
%                    [0,1]
%                  For truecolor images: a 3-element vector in
%                    the range [0,1]
%
%   'Gamma'        A nonnegative scalar indicating the file
%                  gamma
%
%   'Chromaticities' An 8-element vector [wx wy rx ry gx gy bx
%                  by] that specifies the reference white
%                  point and the primary chromaticities 
%
%   'XResolution'  A scalar indicating the number of
%                  pixels/unit in the horizontal direction
%
%   'YResolution'  A scalar indicating the number of
%                  pixels/unit in the vertical direction
%
%   'ResolutionUnit' Either 'unknown' or 'meter'
%
%   'Alpha'        A matrix specifying the transparency of
%                  each pixel individually; the row and column
%                  dimensions must be the same as the data
%                  array; may be uint8, uint16, or double, in
%                  which case the values should be in the
%                  range [0,1]
%
%   'SignificantBits' A scalar or vector indicating how many
%                  bits in the data array should be regarded
%                  as significant; values must be in the range
%                  [1,bitdepth]
%
%                  For indexed images: a 3-element vector
%                  For grayscale images: a scalar
%                  For grayscale images with an alpha channel:
%                    a 2-element vector
%                  For truecolor images: a 3-element vector
%                  For truecolor images with an alpha channel:
%                    a 4-element vector
%
%   In addition to these PNG parameters, you can use any
%   parameter name that satisfies the PNG specification for
%   keywords: only printable characters, 80 characters or
%   fewer, and no leading or trailing spaces.  The value
%   corresponding to these user-specified parameters must be a
%   string that contains no control characters except for
%   linefeed.
%
%   RAS-specific parameters
%   -----------------------
%   'Type'         One of these strings: 'standard'
%                  (uncompressed, b-g-r color order with
%                  truecolor images), 'rgb' (like 'standard',
%                  but uses r-g-b color order for truecolor
%                  images), 'rle' (run-length encoding of 1-bit
%                  and 8-bit images)
%
%   'Alpha'        A matrix specifying the transparency of each
%                  pixel individually; the row and column
%                  dimensions must be the same as the data
%                  array; may be uint8, uint16, or double. May
%                  only be used with truecolor images.
%
%   PBM, PGM, and PPM-specific parameters
%   ------------------------
%   'Encoding'     One of these strings: 'ASCII' for plain encoding
%                  or 'rawbits' for binary encoding.  Default is 'rawbits'.
%   'MaxValue'     A scalar indicating the maximum gray or color
%                  value.  Available only for PGM and PPM files.
%                  For PBM files, this value is always 1.  Default
%                  is 65535 if image array is 'uint16' and 255 otherwise.
%
%   Table: summary of supported image types
%   ---------------------------------------
%   BMP   1-bit, 8-bit and 24-bit uncompressed images
%
%   TIFF  Baseline TIFF images, including 1-bit, 8-bit, 16-bit,
%         and 24-bit uncompressed images; 1-bit, 8-bit, 16-bit, 
%         and 24-bit images with packbits compression; 1-bit 
%         images with CCITT 1D, Group 3, and Group 4 compression;
%         CIELAB, ICCLAB, and CMYK images
%
%   JPEG  Baseline JPEG images
%
%   PNG   1-bit, 2-bit, 4-bit, 8-bit, and 16-bit grayscale
%         images; 8-bit and 16-bit grayscale images with alpha
%         channels; 1-bit, 2-bit, 4-bit, and 8-bit indexed
%         images; 24-bit and 48-bit truecolor images; 24-bit
%         and 48-bit truecolor images with alpha channels
%
%   HDF   8-bit raster image datasets, with or without associated
%         colormap; 24-bit raster image datasets; uncompressed or
%         with RLE or JPEG compression
%
%   PCX   8-bit images
%
%   XWD   8-bit ZPixmaps
%
%   RAS   Any RAS image, including 1-bit bitmap, 8-bit indexed,
%         24-bit truecolor and 32-bit truecolor with alpha.
%
%   PBM   Any 1-bit PBM image, ASCII (plain) or raw (binary) encoding.
%
%   PGM   Any standard PGM image. ASCII (plain) encoded with
%         arbitrary color depth. Raw (binary) encoded with up
%         to 16 bits per gray value.
%
%   PPM   Any standard PPM image. ASCII (plain) encoded with
%         arbitrary color depth. Raw (binary) encoded with up
%         to 16 bits per color component.
%
%   PNM   Any of PPM/PGM/PBM (see above) chosen automatically.
%
%   See also IMFINFO, IMREAD, IMFORMATS, FWRITE, GETFRAME.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:58:32 $

[data, map, filename, format, paramPairs, msg] = parse_inputs(varargin{:});

if (~isempty(msg))
    error('MATLAB:imwrite:inputParsing', msg);
end

if (isempty(data))
    error('MATLAB:imwrite:emptyImage', 'Image data can not be empty.');
end

if (isempty(format))

    format = get_format_from_filename(filename);
    if (isempty(format))
        error('MATLAB:imwrite:fileFormat', 'Unable to determine the file format from the filename.');
    end
    
end

% Signed data may cause unexpected results.
switch (class(data))
case {'int8', 'int16', 'int32', 'int64'}
    warning('MATLAB:imwrite:signedPixelData', ...
            'Unexpected results may occur with signed pixel data.')
end

% Get the format details from the registry.
fmt_s = imformats(format);

% Call the writing function if it exists.
if (~isempty(fmt_s.write))
    feval(fmt_s.write, data, map, filename, paramPairs{:});
else
    error('MATLAB:imwrite:writeFunctionRegistration', 'No writing function for format %s.  See "help imformats".', ...
          format);
end


%%%
%%% Function parse_inputs
%%%
function [data, map, filename, format, paramPairs, msg] = ...
        parse_inputs(varargin)

data = [];
map = [];
filename = '';
format = '';
paramPairs = {};
msg = '';

if (nargin < 2)
    msg = 'Too few input arguments';
    return;
end

firstString = [];
for k = 1:length(varargin)
    if (ischar(varargin{k}))
        firstString = k;
        break;
    end
end

if (isempty(firstString))
    msg = 'Invalid input arguments: missing filename';
    return;
end

switch firstString
case 1
    msg = 'Invalid input arguments: first argument should not be a string';
    return;
    
case 2
    % imwrite(data, filename, ...)
    data = varargin{1};
    filename = varargin{2};
    
case 3
    % imwrite(data, map, filename, ...)
    data = varargin{1};
    map = varargin{2};
    filename = varargin{3};
    if (size(map,2) ~= 3)
        msg = 'Invalid colormap';
        return;
    end
    
    if ((min(map(:)) < 0) || (max(map(:)) > 1))
        warning('MATLAB:imwrite:colormapRange', 'Colormap data should be in the range 0 to 1.')
    end

otherwise
    msg = 'Invalid input arguments: missing filename';
    return;
end

if (length(varargin) > firstString)
    % There are additional arguments after the filename.
    if (~ischar(varargin{firstString + 1}))
        msg = 'Invalid input arguments.';
        return;
    end
    
    % Is the argument after the filename a format specifier?
    fmt_s = imformats(varargin{firstString + 1});
    
    if (~isempty(fmt_s))
        % imwrite(..., filename, fmt, ...)
        format = varargin{firstString + 1};
        paramPairs = varargin((firstString + 2):end);
        
    else
        % imwrite(..., filename, prop1, val1, prop2, val2, ...)
        paramPairs = varargin((firstString + 1):end);
    end
    
end

% Do some validity checking on param-value pairs
if (rem(length(paramPairs), 2) ~= 0)
    msg = 'Invalid input syntax';
    return;
end

for k = 1:2:length(paramPairs)
    if (~ischar(paramPairs{k}))
        msg = 'Parameter names must be strings';
        return;
    end
end

%%%
%%% Function get_format_from_filename
%%%
function format = get_format_from_filename(filename)

format = '';

idx = find(filename == '.');

if (~isempty(idx))
  
    ext = filename((idx(end) + 1):end);
    fmt_s = imformats(ext);
    
    if (~isempty(fmt_s))
        format = ext;
    end
    
end
