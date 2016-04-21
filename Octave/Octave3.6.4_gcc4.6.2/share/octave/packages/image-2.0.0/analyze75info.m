%% Copyright (C) 2012 Adam H Aitkenhead <adamaitkenhead@hotmail.com>
%% Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {@var{header} =} analyze75info (@var{filename})
%% @deftypefnx {Function File} {@var{header} =} analyze75info (@var{filename}, "ByteOrder", @var{arch})
%% Read header of an Analyze 7.5 file.
%%
%% @var{filename} must be the path for an Analyze 7.5 file or the path for a
%% directory with a single .hdr file can be specified.
%%
%% The optional argument @code{"ByteOrder"} reads the file with the specified
%% @var{arch} ("ieee-be" or "ieee-le" for IEEE big endian or IEEE
%% little endian respectively).
%%
%% @var{header} is a structure with the file information.
%%
%% @seealso{analyze75read, analyze75write}
%% @end deftypefn

function header = analyze75info (filename, varargin)

  if (nargin ~= 1 && nargin ~= 3)
    print_usage;
  elseif (~ischar (filename))
    error ('analyze75info: `filename'' must be a string');
  elseif (nargin == 3)
    %% Check the byteorder
    if (strcmpi (varargin{1}, 'byteorder'))
      error ('analyze75info: second argument must be string `ByteOrder''');
    elseif (!all (strcmpi (varargin{3}, {'ieee-le', 'l', 'ieee-be', 'b'})))
      error ('analyze75info: valid options for `ByteOrder'' are `ieee-le'' or `ieee-be''');
    elseif (any (strcmpi (varargin{3}, {'ieee-be', 'b'})))
      warning ('analyze75info: no support for big-endian. Please consider submitting a patch. Attempting to read as little-endian');
    end
  end

  fileprefix = analyze75filename (filename);

  %% finally start reading the actual file
  hdrdirdata              = dir ([fileprefix, '.hdr']);
  imgdirdata              = dir ([fileprefix, '.img']);

  header.ImgFileSize      = imgdirdata.bytes;

  header.Filename         = [fileprefix, '.hdr'];
  header.FileModDate      = hdrdirdata.date;
  header.Format           = 'Analyze';
  header.FormatVersion    = '7.5';
  header.ColorType        = 'grayscale';
  header.ByteOrder        = 'ieee-le';

  fidH                    = fopen ([fileprefix, '.hdr']);

  header.HdrFileSize      = fread (fidH, 1, 'int32');
  header.HdrDataType      = char (fread (fidH, 10, 'char'))';
  header.DatabaseName     = char (fread (fidH, 18, 'char'))';
  header.Extents          = fread (fidH, 1, 'int32');
  header.SessionError     = fread (fidH, 1, 'int16');
  header.Regular          = char (fread (fidH, 1, 'char'));
  unused                  = char (fread (fidH, 1, 'char'));
  unused                  = fread (fidH, 1, 'int16');
  header.Dimensions       = zeros (size (1, 4));
  header.Dimensions(1)    = fread (fidH, 1, 'int16');
  header.Dimensions(2)    = fread (fidH, 1, 'int16');
  header.Dimensions(3)    = fread (fidH, 1, 'int16');
  header.Dimensions(4)    = fread (fidH, 1, 'int16');
  unused                  = fread (fidH, 3, 'int16');
  header.VoxelUnits       = char (fread (fidH, 4, 'char'))';
  header.CalibrationUnits = char (fread (fidH, 8, 'char'))';
  unused                  = fread (fidH, 1, 'int16');

  datatype = fread (fidH, 1, 'int16');
  switch datatype
  case   0, header.ImgDataType = 'DT_UNKNOWN';
  case   1, header.ImgDataType = 'DT_BINARY';
  case   2, header.ImgDataType = 'DT_UNSIGNED_CHAR';
  case   4, header.ImgDataType = 'DT_SIGNED_SHORT';
  case   8, header.ImgDataType = 'DT_SIGNED_INT';
  case  16, header.ImgDataType = 'DT_FLOAT';
  case  32, header.ImgDataType = 'DT_COMPLEX';
  case  64, header.ImgDataType = 'DT_DOUBLE';
  case 128, header.ImgDataType = 'DT_RGB';
  case 255, header.ImgDataType = 'DT_ALL';
  otherwise, warning ('analyze75: unable to detect ImgDataType');
  end

  header.BitDepth           = fread (fidH, 1, 'int16');
  unused                    = fread (fidH, 1, 'int16');
  unused                    = fread (fidH, 1, 'float');
  header.PixelDimensions    = zeros (1, 3);
  header.PixelDimensions(1) = fread (fidH, 1, 'float');
  header.PixelDimensions(2) = fread (fidH, 1, 'float');
  header.PixelDimensions(3) = fread (fidH, 1, 'float');
  unused                    = fread (fidH, 4, 'float');
  header.VoxelOffset        = fread (fidH, 1, 'float');
  unused                    = fread (fidH, 3, 'float');
  header.CalibrationMax     = fread (fidH, 1, 'float');
  header.CalibrationMin     = fread (fidH, 1, 'float');
  header.Compressed         = fread (fidH, 1, 'float');
  header.Verified           = fread (fidH, 1, 'float');
  header.GlobalMax          = fread (fidH, 1, 'int32');
  header.GlobalMin          = fread (fidH, 1, 'int32');
  header.Descriptor         = char (fread (fidH, 80, 'char'))';
  header.AuxFile            = char (fread (fidH, 24, 'char'))';
  header.Orientation        = char (fread (fidH, 1,  'char'))';
  header.Originator         = char (fread (fidH, 10, 'char'))';
  header.Generated          = char (fread (fidH, 10, 'char'))';
  header.Scannumber         = char (fread (fidH, 10, 'char'))';
  header.PatientID          = char (fread (fidH, 10, 'char'))';
  header.ExposureDate       = char (fread (fidH, 10, 'char'))';
  header.ExposureTime       = char (fread (fidH, 10, 'char'))';
  unused                    = char (fread (fidH, 3,  'char'))';
  header.Views              = fread (fidH, 1, 'int32');
  header.VolumesAdded       = fread (fidH, 1, 'int32');
  header.StartField         = fread (fidH, 1, 'int32');
  header.FieldSkip          = fread (fidH, 1, 'int32');
  header.OMax               = fread (fidH, 1, 'int32');
  header.OMin               = fread (fidH, 1, 'int32');
  header.SMax               = fread (fidH, 1, 'int32');
  header.SMin               = fread (fidH, 1, 'int32');

  header.Width              = header.Dimensions(1);
  header.Height             = header.Dimensions(2);

  fclose(fidH);
end
