## Copyright (C) 2009 Roderick Koehle <koehle@users.sourceforge.net>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{exif} =} readexif(@var{filename}, @var{thumbnail})
## Read EXIF information from JPEG image data.
##
## The exif tag information are returned in the @var{exif} data structure.
## Integer ratios are expressed as column vector.
## For example, a focal number of 2.8 is expressed
## as FNumber=[28; 10]. Otherwise all data are returned by the type
## as specified in the IFD structures.
##
## The filename for the thumbnail image is optional.
## If given, the thumbnail jpeg image will be stored to
## file @var{thumbnail}. 
##
## Reference:
## JEITA CP-3451, Exchangeable image file format for digital still cameras:
## Exif Version 2.2
##
## @seealso{imwrite, imfinfo}
## @end deftypefn

function exif = readexif(file, thumbnail)

  if (nargin < 1 || nargin > 2)
    print_usage;
  endif

  % Enable the debug flag to see more of the JPG sections.

  debug = false;

  [in, msg] = fopen(file);
  if (in<0)
    error ("readexif: could not open `%s': %s", file, msg);
  end

  s = fread(in, 1, 'uint16', 'ieee-be');

  JPEG.SOI = 0xffd8;
  JPEG.APP0 = 0xffe0;
  JPEG.APP1 = 0xffe1;
  JPEG.APP2 = 0xffe2;
  JPEG.DQT = 0xffdb;
  JPEG.DHT = 0xffc4;
  JPEG.DRI = 0xffdd;
  JPEG.SOF = 0xffc0;
  JPEG.SOS = 0xffda;
  JPEG.EOI = 0xffd9;

  % Stop if no Start of Image found

  if s~=JPEG.SOI
    error('JPEG Format error - missing start of image tag.');
  end

  exif = [];

  while ~feof(in)
    s = fread(in, 1, 'uint16', 'ieee-be');

    switch s
      case JPEG.SOI
      case JPEG.APP0
        l = fread(in, 1, 'uint16', 'ieee-be');
        if debug, printf('APP0: %i\n', l); end
        fseek(in, l-2, 'cof');
      case JPEG.APP1
        l = fread(in, 1, 'uint16', 'ieee-be');
        if debug, printf('APP1: %i\n', l); end
        app1 = fread(in, l-2, 'uchar');
        if nargin==1
          exif = parseexif(app1);
        else
          exif = parseexif(app1, thumbnail);
        end
        % stop reading further, remove following break
        % if you want to extend this parser.
        break; 
      case JPEG.APP2
        l = fread(in, 1, 'uint16', 'ieee-be');
        if debug, printf('APP2: %i\n', l); end
        fseek(in, l-2, 'cof');
      case JPEG.DQT % define quantization table
        l = fread(in, 1, 'uint16', 'ieee-be');
        if debug, printf('DQT: %i\n', l); end;
        fseek(in, l-2, 'cof');
      case JPEG.DHT % define huffmann table
        l = fread(in, 1, 'uint16', 'ieee-be');
        fseek(in, l-2, 'cof');
        if debug, printf('DHT: %i\n', l); end
      case JPEG.DRI % define restart interoperability
        l = fread(in, 1, 'uint16', 'ieee-be');
        fseek(in, l-2, 'cof');
        if debug, printf('DRI: %i\n', l); end
      case JPEG.SOF % start of frame
        l = fread(in, 1, 'uint16', 'ieee-be');
        fseek(in, l-2, 'cof');
        if debug, printf('SOF: %i\n', l); end
      case JPEG.SOS % start of scan
        l = fread(in, 1, 'uint16', 'ieee-be');
        fseek(in, l-2, 'cof');
        if debug, printf('SOS: %i\n', l); end

        % JPEG compressed data comes here ...
        break;

      case JPEG.EOI % end of image
        printf('EOI');
      otherwise % Skip unknown tags
        l = fread(in, 1, 'uint16', 'ieee-be');
        if debug, printf('TAG %04X: %i\n', s, l); end
        fseek(in, l-2, 'cof');
    end
  end

  fclose(in);
end

%
% Parse EXIF APP1 section
%
% This routine will parse the APP1 section of an jpeg image.
% If a filename "thumb" is given, the tumbnail image data
% will be exported to given file.
%
%   exif = parseexif(data, thumb)
%
function exif = parseexif(data, thumb)

  id = char(data(1:6).');
  if strncmp(id, ['Exif' 0 0], 6)

    % TIFF header

    byteorder = char(data(7:8).');
    littleendian = strncmp(byteorder, 'II', 2);
    bigendian    = strncmp(byteorder, 'MM', 2);

    tag42     = intn(data(9:10), bigendian);
    offset    = intn(data(11:14), bigendian);

    if (~littleendian && ~bigendian) || tag42~=42
      error('invalid TIFF header');
    end

    % IFD fields

    exif = ifdparse(tifftags(), data, offset, bigendian);
  else
    exif = [];
  end

  % export thumbnail image

  if nargin==2 && isfield(exif, 'JPEGInterchangeFormat')
    i = exif.JPEGInterchangeFormat;
    n = exif.JPEGInterchangeFormatLength;

    jpg = data(7+i:7+i+n-1);
    out = fopen(thumb, 'w');
    if (out<0), 
      error('Cannot open file "%s" for writing thumbnail image.', thumb);
    end
    fwrite(out, jpg, 'uint8');
    fclose(out);
  end
end

function ifd = ifdparse(dict, data, offset, endian)

  debug = false;

  ifd = [];

  while offset
    ifd_fields = intn(data(7+offset+(0:1)), endian);

    if debug, printf('Tag  Type Count    Offset\n'); end
    for i=1:ifd_fields
      j = 9+offset+(i-1)*12;
      ifd_tag    = intn(data(  j:j+1), endian);
      ifd_type   = intn(data(j+2:j+3), endian);
      ifd_count  = intn(data(j+4:j+7), endian);
      ifd_offset = intn(data(j+8:j+11), endian);

      name = ifdtagname(dict, ifd_tag);

      if debug,
        printf('%04x %04x %08x %08x %s : ', ifd_tag, ifd_type, ...
               ifd_count, ifd_offset, name);
      end
      if ifd_type>0
        n = ifdsize(ifd_type);

        if n*ifd_count<=4
          value = data(j+8:j+8+n*ifd_count-1);
          value = reshape(value, n, ifd_count);
        else
          a = 7+ifd_offset;
          b = 7+ifd_offset+n*ifd_count-1;
          if (a>0 && b>0 && a<=length(data) && b<=length(data))
            value = data(7+ifd_offset:7+ifd_offset+n*ifd_count-1);
            value = reshape(value, n, ifd_count);
          else
            value = [];
          end
        end
      end
   
      switch ifd_type
        case 01 % unsigned char
          ifd.(name) = uint8(value);
          if debug,
            printf('%02x ', uint8(value));
            printf('\n');
          end
        case 02 % Ascii
          ifd.(name) = char(value);
          if debug, printf('%s\n', char(value)); end
        case 03 % 16 bit unsigned int
          ifd.(name) = uintn(value, endian);
          if debug
            printf('%i ', intn(value), endian);
            printf('\n');
          end
        case 04 % 32 bit unsigned int
          ifd.(name) = uintn(value, endian);
          if debug, printf('%i\n', uintn(value, endian)); end
        case 05 % 32 bit unsigned rational
          ifd.(name) = [uintn(value(1:4,:), endian); uintn(value(5:8,:), endian)];
          if debug, printf('%i/%i\n',uintn(value(1:4), endian),uintn(value(5:8)), endian); end
        case 07 % unknown
          ifd.(name) = uint8(value);
          if debug
            printf('%02x ', value);
            printf('\n');
          end
        case 09 % 32 bit signed int
          ifd.(name) = intn(value, endian);
          if debug, printf('%i\n', intn(value, endian)); end
        case 10 % 32 bit signed rational
          ifd.(name) = [intn(value(1:4,:), endian); intn(value(5:8,:), endian)];
          if debug, printf('%i/%i\n',intn(value(1:4), endian),intn(value(5:8)), endian); end
        otherwise
          printf('%02x ', value);
          printf('\n');
      end

      switch ifd_tag
        case 0x8769, % Exif Pointer
          ifd.(name) = ifdparse(exiftags(), data, ifd_offset, endian);
        case 0x8825, % GPS Pointer
          ifd.(name) = ifdparse(gpstags(), data, ifd_offset, endian);
        case 0xa005 % Interoperatibility Pointer
          ifd.(name) = ifdparse(dict, data, ifd_offset, endian);
%        case 0x927c % Makernotes
%           ifd.(name) = ifdparse([], data, ifd_offset, endian);
        otherwise
      end
    end
    j = 9+offset+ifd_fields*12;
    ifd_next = intn(data(j:j+3), endian);

    offset = ifd_next;
  end
end

%
% Return bytelength for respective IFD type
%
function n = ifdsize(ifd_type)
  switch ifd_type
    case {1, 2, 7}, n = 1;
    case 03       , n = 2;
    case {4, 9}   , n = 4;
    case {5, 10}  , n = 8;
    otherwise     , n = 1;
  end
end


%
% Convert little endian character vector to integer
%
function y = intn(x, bigendian)
  if bigendian
    y = polycol(x, int32(256));
  else
    y = polycol(flipud(x), int32(256));
  end
end

function y = uintn(x, bigendian)
  if bigendian
     y = polycol(x, uint32(256));
  else
     y = polycol(flipud(x), uint32(256));
  end
end

%
% Use own polyval that works with integers,
% it evaluates the number polygon columnwise.
%
%   number = polycol(digits, base)
%
function y = polycol(c, x)
  y = c(1,:);
  for i=2:size(c, 1)
    y = y.*x+c(i,:);
  end
end

%
% Query EXIF IFD tagname
%
% Unfortunately, neither MATLAB nor Octave provide a hash functionality,
% so use structures as hash.
%
function name = ifdtagname(dict, key)
  k = sprintf('K%04X', key);
  if isfield(dict, k)
    name = dict.(k);
  else
    name = sprintf('tag%04X', key);
  end
end

%
% Primary image IFD tags according to Exif 2.2
%
function dict = tifftags()
  t = {

    % TIFF Tags according to EXIF2.2, additional baseline TIFF tags are marked by a '%'

    '0FE' 'NewSubfileType' %
    '0FF' 'SubfileType' %
    '100' 'ImageWidth'
    '101' 'ImageLength'
    '102' 'BitsPerSample'
    '103' 'Compression'
    '106' 'PhotometricInterpretation'
    '108' 'CellWidth' %
    '109' 'CellLength' %
    '10A' 'FillOrder' %
    '10E' 'ImageDescription'
    '10F' 'Make'
    '110' 'Model'
    '111' 'StripOffsets'
    '112' 'Orientation'
    '115' 'SamplesPerPixel'
    '116' 'RowsPerStrip'
    '117' 'StripByteCounts'
    '118' 'MinSampleValue' %
    '119' 'MaxSampleValue' %
    '11A' 'XResolution'
    '11B' 'YResolution'
    '11C' 'PlanarConfiguration'
    '120' 'FreeOffsets' %
    '121' 'FreeByteCounts' %
    '122' 'GrayResponseUnit' %
    '123' 'GrayResponseCurve' %
    '128' 'ResolutionUnit'
    '12D' 'TransferFunction'
    '131' 'Software'
    '132' 'DateTime'
    '13B' 'Artist'
    '13C' 'HostComputer' %
    '13E' 'WhitePoint'
    '13F' 'PrimaryChromaticities'
    '140' 'ColorMap' %
    '152' 'ExtraSamples' %
    '201' 'JPEGInterchangeFormat'
    '202' 'JPEGInterchangeFormatLength'
    '211' 'YCbCrCoefficients'
    '212' 'YCbCrSubSampling'
    '213' 'YCbCrPositioning'
    '214' 'ReferenceBlackWhite'
    '8298' 'Copyright'
    '8769' 'Exif IFD Pointer'
    '8825' 'GPS Info IFD Pointer'
  };

  dict = [];
  for i=1:size(t,1)
    key   = sprintf('K%04X', hex2dec(t{i,1}));
    value = t{i,2};
    dict.(key) = strrep(value, ' ', '_');
  end
end

%
% EXIF private tags
%
function dict = exiftags()
  t = {

    % EXIF Tags

    '829A' 'ExposureTime'
    '829D' 'FNumber'
    '8822' 'ExposureProgram'
    '8824' 'SpectralSensitivity'
    '8827' 'ISOSpeedRatings'
    '8828' 'OECF'
    '9000' 'ExifVersion'
    '9003' 'DateTimeOriginal'
    '9004' 'DateTimeDigitized'
    '9101' 'ComponentsConfiguration'
    '9102' 'CompressedBitsPerPixel'
    '9201' 'ShutterSpeedValue'
    '9202' 'ApertureValue'
    '9203' 'BrightnessValue'
    '9204' 'ExposureBiasValue'
    '9205' 'MaxApertureValue'
    '9206' 'SubjectDistance'
    '9207' 'MeteringMode'
    '9208' 'LightSource'
    '9209' 'Flash'
    '920A' 'FocalLength'
    '9214' 'SubjectArea'
    '927C' 'MakerNote'
    '9286' 'UserComment'
    '9290' 'SubsecTime'
    '9291' 'SubsecTimeOriginal'
    '9292' 'SubsecTimeDigitized'
    'A000' 'FlashpixVersion'
    'A001' 'ColorSpace'
    'A002' 'PixelXDimension'
    'A003' 'PixelYDimension'
    'A004' 'RelatedSoundFile'
    'A005' 'Interoperatibility IFD Pointer'
    'A20B' 'FlashEnergy'
    'A20C' 'SpatialFrequencyResponse'
    'A20E' 'FocalPlaneXResolution'
    'A20F' 'FocalPlaneYResolution'
    'A210' 'FocalPlaneResolutionUnit'
    'A214' 'SubjectLocation'
    'A215' 'ExposureIndex'
    'A217' 'SensingMethod'
    'A300' 'FileSource'
    'A301' 'SceneType'
    'A302' 'CFAPattern'
    'A401' 'CustomRendered'
    'A402' 'ExposureMode'
    'A403' 'WhiteBalance'
    'A404' 'DigitalZoomRatio'
    'A405' 'FocalLengthIn35mmFilm'
    'A406' 'SceneCaptureType'
    'A407' 'GainControl'
    'A408' 'Contrast'
    'A409' 'Saturation'
    'A40A' 'Sharpness'
    'A40B' 'DeviceSettingDescription'
    'A40C' 'SubjectDistanceRange'
    'A420' 'ImageUniqueID'

    % Interoperatibility tags

    '001' 'InteroperatibilityIndex'
    '002' 'InteroperatibilityVersion'
    '1000' 'RelatedImageFileFormat'
    '1001' 'RelatedImageWidth'
    '1002' 'RelatedImageLength'
  };

  dict = [];
  for i=1:size(t,1)
    key   = sprintf('K%04X', hex2dec(t{i,1}));
    value = t{i,2};
    dict.(key) = strrep(value, ' ', '_');
  end
end

%
% EXIF GPS tags
%
function dict = gpstags()
  t = {
    0 'GPSVersionID'
    1 'GPSLatitudeRef'
    2 'GPSLatitude'
    3 'GPSLongitudeRef'
    4 'GPSLongitude'
    5 'GPSAltitudeRef'
    6 'GPSAltitude'
    7 'GPSTimeStamp'
    8 'GPSSatellites'
    9 'GPSStatus'
    10 'GPSMeasureMode'
    11 'GPSDOP'
    12 'GPSSpeedRef'
    13 'GPSSpeed'
    14 'GPSTrackRef'
    15 'GPSTrack'
    16 'GPSImgDirectionRef'
    17 'GPSImgDirection'
    18 'GPSMapDatum'
    19 'GPSDestLatitudeRef'
    20 'GPSDestLatitude'
    21 'GPSDestLongitudeRef'
    22 'GPSDestLongitude'
    23 'GPSDestBearingRef'
    24 'GPSDestBearing'
    25 'GPSDestDistanceRef'
    26 'GPSDestDistance'
  };

  dict = [];
  for i=1:size(t,1)
    key   = sprintf('K%04X', t{i,1});
    value = t{i,2};
    dict.(key) = strrep(value, ' ', '_');
  end
end

