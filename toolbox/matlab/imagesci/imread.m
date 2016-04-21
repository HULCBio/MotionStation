function [X, map, alpha] = imread(varargin)
%IMREAD Read image from graphics file.
%   A = IMREAD(FILENAME,FMT) reads a grayscale or color image from the
%   file specified by the string FILENAME, where the string FMT specifies
%   the format of the file.  See the reference page, or the output of the
%   function IMFORMATS, for a list of supported formats.  If the file is
%   not in the current directory or in a directory in the MATLAB path,
%   specify the full pathname of the location on your system.  If IMREAD
%   cannot find a file named FILENAME, it looks for a file named
%   FILENAME.FMT.
%
%   IMREAD returns the image data in the array A.  If the file contains a
%   grayscale image, A is a two-dimensional (M-by-N) array.  If the file
%   contains a color image, A is a three-dimensional (M-by-N-by-3)
%   array.  The class of the returned array depends on the data type used
%   by the file format.
%
%   For most file formats, the color image data returned uses the RGB
%   color space.  For TIFF files, however, IMREAD can return color data
%   that uses the RGB, CIELAB, ICCLAB, or CMYK color spaces.  If the
%   color image uses the CMYK color space, A is an M-by-N-by-4 array.
%   See the reference page for more information about reading TIFF files
%   that use these color spaces.
%
%   [X,MAP] = IMREAD(FILENAME,FMT) reads the indexed image in FILENAME
%   into X and its associated colormap into MAP. Colormap values in the
%   image file are automatically rescaled into the range [0,1]. 
%
%   [...] = IMREAD(FILENAME) attempts to infer the format of the file
%   from its content.
%
%   [...] = IMREAD(URL,...) reads the image from an Internet URL.  The
%   URL must include the protocol type (e.g., "http://"). 
%
%   Data types
%   ----------
%   In most of the image file formats supported by IMREAD,
%   pixels are stored using 8 or fewer bits per color plane.
%   If the file contains only 1 bit per pixel, the class of the
%   output (A or X) is logical.  When reading other files with
%   8 or fewer bits per color plane, the class of the output
%   is uint8.  IMREAD also supports reading 16-bit-per-pixel
%   data from BMP, PNG, JPEG, and TIFF files, as well as 12-bit
%   JPEG files. For 12-bit JPEG and 16-bit JPEG, PNG, and TIFF
%   image files, the class of the output (A or X) is uint16 and
%   for 16-bit BMP image files, the class of the output is uint8.
%
%   TIFF-specific syntaxes
%   ----------------------
%   [...] = IMREAD(...,IDX) reads in one image from a
%   multi-image TIFF file.  IDX is an integer value that
%   specifies the order that the image appears in the file.
%   For example, if IDX is 3, IMREAD reads the third image in
%   the file.  If you omit this argument, IMREAD reads the
%   first image in the file.
%
%   [...] = IMREAD(...,'PixelRegion',{ROWS, COLS}) returns the sub-image
%   specified by the boundaries in ROWS and COLS.  In the case of tiled
%   TIFF images, IMREAD will read only the appropriate tiles, improving
%   memory efficiency and performance.  ROWS and COLS must be either two
%   or three element vectors.  If two elements are provided, they denote
%   the 1-based indices [START STOP].  If three elements are provided,
%   the indices [START INCREMENT STOP] allow image downsampling.
%
%   PNG-specific syntaxes
%   ---------------------
%   [...] = IMREAD(...,'BackgroundColor',BG) composites any
%   transparent pixels in the input image against the color
%   specified in BG.  If BG is 'none', then no compositing is
%   performed. Otherwise, if the input image is indexed, BG
%   should be an integer in the range [1,P] where P is the
%   colormap length. If the input image is grayscale, BG
%   should be an integer in the range [0,1].  If the input
%   image is RGB, BG should be a three-element vector whose
%   values are in the range [0,1]. The string
%   'BackgroundColor' may be abbreviated.  
%
%   If the ALPHA output argument is used (see below), then BG
%   defaults to 'none' if not specified by the
%   user. Otherwise, if the PNG file contains a background
%   color chunk, that color is used as the default value for
%   BG. If ALPHA is not used and the file does not contain a
%   background color chunk, then the default value for BG is 1
%   for indexed images; 0 for grayscale images; and [0 0 0]
%   for RGB images.  
%
%   [A,MAP,ALPHA] = IMREAD(...) returns the alpha channel if
%   one is present; otherwise ALPHA is [].  Note that MAP may
%   be empty if the file contains a grayscale or truecolor 
%   image.
%
%   HDF-specific syntaxes
%   ---------------------
%   [...] = IMREAD(...,REF) reads in one image from a
%   multi-image HDF file.  REF is an integer value that
%   specifies the reference number used to identify the image.
%   For example, if REF is 12, IMREAD reads the image whose
%   reference number is 12.  (Note that in an HDF file the
%   reference numbers do not necessarily correspond with the
%   order of the images in the file.  You can use IMFINFO to
%   match up image order with reference number.)  If you omit
%   this argument, IMREAD reads the first image in the file.
%
%   ICO- and CUR-specific syntaxes
%   ------------------------------
%   [...] = IMREAD(...,IDX) reads in one image from a
%   multi-image icon or cursor file.  IDX is an integer value
%   that specifies the order that the image appears in the file.
%   For example, if IDX is 3, IMREAD reads the third image in
%   the file.  If you omit this argument, IMREAD reads the
%   first image in the file. 
%
%   [A,MAP,ALPHA] = IMREAD(...) returns the AND mask for the
%   resource, which can be used to determine the transparency
%   information.  For cursor files, this mask may contain the
%   only useful data.
%
%   GIF-specific syntaxes
%   ---------------------
%   [...] = IMREAD(...,IDX) reads in one or more frames from a
%   multiframe (i.e., animated) GIF file.  IDX must be an integer
%   scalar or vector of integer values.  For example, if IDX is 3,
%   IMREAD reads the third image in the file.  If IDX is 1:5, only
%   the first five frames will be returned.
%
%   [...] = IMREAD(...,'Frames',IDX) is the same as the syntax
%   above except that IDX can be 'all'.  In this case, all of the
%   frames are read and returned in the order that they appear in
%   the file.
%
%   Note: Because of the way that GIF files are structured, all of
%   the frames must be read when a particular frame is requested.
%   Consequently, it is much faster to specify a vector of frames
%   or 'all' for IDX than to call IMREAD in a loop when reading
%   multiple frames from the same GIF file.
%
%   Supported file types
%   --------------------
%   JPEG  Any baseline JPEG image; JPEG images with some
%         commonly used extensions; 8-bit and 12-bit lossy
%         compressed RGB and grayscale images; 8-bit and 12-bit
%         lossless compressed RGB images; 8-bit, 12-bit, and
%         16-bit lossless compressed grayscale images
%
%   TIFF  Any baseline TIFF image, including 1-bit, 8-bit, and
%         24-bit uncompressed images; 1-bit, 8-bit, and 24-bit
%         images with packbits compression; 1-bit images with
%         CCITT compression; 16-bit grayscale, 16-bit indexed, 
%         and 48-bit RGB images; 24-bit and 48-bit ICCLAB
%         and CIELAB images; 32-bit and 64-bit CMYK images; and
%         8-bit tiled TIFF images with any compression and colorspace
%         combination listed above.
%
%   GIF   Any 1-bit to 8-bit GIF image
%
%   BMP   1-bit, 4-bit, 8-bit, 16-bit, 24-bit, and 32-bit uncompressed
%         images; 4-bit and 8-bit run-length encoded (RLE) images
%
%   PNG   Any PNG image, including 1-bit, 2-bit, 4-bit, 8-bit,
%         and 16-bit grayscale images; 8-bit and 16-bit
%         indexed images; 24-bit and 48-bit RGB images
%
%   HDF   8-bit raster image datasets, with or without an
%         associated colormap; 24-bit raster image datasets
%
%   PCX   1-bit, 8-bit, and 24-bit images
%
%   XWD   1-bit and 8-bit ZPixmaps; XYBitmaps; 1-bit XYPixmaps
%
%   ICO   1-bit, 4-bit, and 8-bit uncompressed images
%
%   CUR   1-bit, 4-bit, and 8-bit uncompressed images
%
%   RAS   Any RAS image, including 1-bit bitmap, 8-bit indexed,
%         24-bit truecolor and 32-bit truecolor with alpha.
%
%   PBM   Any 1-bit PBM image.  Raw (binary) or ASCII (plain) encoded.
%
%   PGM   Any standard PGM image.  ASCII (plain) encoded with
%         arbitrary color depth.  Raw (binary) encoded with up
%         to 16 bits per gray value.
%
%   PPM   Any standard PPM image.  ASCII (plain) encoded with
%         arbitrary color depth. Raw (binary) encoded with up
%         to 16 bits per color component.
%
%   See also IMFINFO, IMWRITE, IMFORMATS, FREAD, IMAGE, DOUBLE, UINT8.

%   Steven L. Eddins, June 1996
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/01 16:12:26 $

[filename, format, extraArgs, msg] = parse_inputs(varargin{:});
if (~isempty(msg))
    error('MATLAB:imread:inputParsing', '%s', msg);
end

% Download remote file.
if (strfind(filename, '://'))
  
    url = true;
  
    if (~usejava('mwt'))
        error('MATLAB:imread:noJava', 'Reading from a URL requires a Java Virtual Machine.')
    end
    
    try
        filename = urlwrite(filename, tempname);
    catch
        error('MATLAB:imread:readURL', 'Can''t read URL "%s".', filename);
    end
    
else
  
    url = false;

end


if (isempty(format))
    % The format was not specified explicitly.
    
    % Verify that the file exists.
    fid = fopen(filename, 'r');
    if (fid == -1)
      
        if ~isempty(dir(filename))
            error('MATLAB:imread:fileOpen', ['Can''t open file "%s" for reading;\nyou' ...
                   ' may not have read permission.'], ...
                  filename);
        else
            error('MATLAB:imread:fileOpen', 'File "%s" does not exist.', filename);
        end

    else
        % File exists.  Get full filename.
        filename = fopen(fid);
        fclose(fid);
    end
    
    % Try to determine the file type.
    format = imftype(filename);

    if (isempty(format))
        error('MATLAB:imread:fileFormat', 'Unable to determine the file format.');
    end
    
else
    % The format was specified explicitly.
    
    % Verify that the file exists.
    fid = fopen(filename, 'r');
    if (fid == -1)
        % Couldn't open using the given filename; search for a
        % file with an appropriate extension.
        fmt_s = imformats(format);
        
        if (isempty(fmt_s))
            error('MATLAB:imread:fileFormat', ['Couldn''t find format %s in the format registry.' ...
                   '  See "help imformats".'], format);
        end
            
        for p = 1:length(fmt_s.ext)
            fid = fopen([filename '.' fmt_s.ext{p}]);
            
            if (fid ~= -1)
                % The file was found.  Don't continue searching.
                break
            end
        end
    end
    
    if (fid == -1)
        if ~isempty(dir(filename))
            error('MATLAB:imread:fileOpen', ['Can''t open file "%s" for reading;\nyou' ...
                   ' may not have read permission.'], ...
                  filename);
        else
            error('MATLAB:imread:fileOpen', 'File "%s" does not exist.', filename);
        end
    else
        filename = fopen(fid);
        fclose(fid);
    end
    
end

% Get format details.
fmt_s = imformats(format);

% Verify that a read function exists
if (isempty(fmt_s.read))
    error('MATLAB:imread:readFunctionRegistration', 'No reading function for format %s.  See "help imformats".', ...
          fmt_s.ext{1});
end

if ((fmt_s.alpha) && (nargout == 3))
  
    % Use the alpha channel.
    [X, map, alpha] = feval(fmt_s.read, filename, extraArgs{:});
    
else

    % Alpha channel is not requested or is not applicable.
    alpha = [];
    [X, map] = feval(fmt_s.read, filename, extraArgs{:});
    
end

% Delete temporary file from Internet download.
if (url)
    delete_download(filename);
end



%%%
%%% Function delete_download
%%%
function delete_download(filename)

try
    delete(filename);
catch
    warning('MATLAB:imread:tempFileDelete', 'Can''t delete temporary file "%s".', filename)
end


      

%%%
%%% Function parse_inputs
%%%
function [filename, format, extraArgs, msg] = ...
        parse_inputs(varargin)

filename = '';
format = '';
extraArgs = {};
msg = '';

% Parse arguments based on their number.
switch(nargin)
case 0

    % Not allowed.
    msg = 'Too few input arguments.';
    return;
    
case 1

    % Filename only.
    filename = varargin{1};
    
otherwise

    % Filename and format or other arguments.
    filename = varargin{1};
    
    % Check whether second argument is a format.
    if (ischar(varargin{2}))
        fmt_s = imformats(varargin{2});
    else
        fmt_s = struct([]);
    end
    
    if (~isempty(fmt_s))
        % The argument matches a format.
        format = varargin{2};
        extraArgs = varargin(3:end);
    else
        % The argument begins the format-specific parameters.
        extraArgs = varargin(2:end);
    end
    
end
