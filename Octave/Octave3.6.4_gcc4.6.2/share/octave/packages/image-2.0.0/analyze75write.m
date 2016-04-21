%% Copyright (C) 2012 Adam H Aitkenhead <adamaitkenhead@hotmail.com>
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
%% @deftypefn {Function File} analyze75write (@var{filename}, @var{data}, @var{header})
%% @deftypefnx {Function File} analyze75write (@var{filename}, @var{data}, @var{x}, @var{y}, @var{z})
%% @deftypefnx {Function File} analyze75write (@var{filename}, @var{data}, @var{header}, @var{x}, @var{y}, @var{z})
%% Write image data to an Analyze 7.5 file.
%%
%% @var{filename} is the path to write the Analyze 7.5 file; @var{data} is
%% the 3D image data; @var{header} is a structure containing the file
%% information;  @var{x}, @var{y}, @var{z} are lists of the x,y,z coordinates
%% (in cm) of the data grid.
%%
%% @seealso{analyze75info, analyze75read}
%% @end deftypefn

%% Author: Adam H. Aitkenhead <adamaitkenhead@hotmail.com>

function analyze75write (varargin);

  if (nargin ~= 3 && nargin ~= 5 && nargin ~= 6)
    print_usage;
  else
    filename = varargin{1};
    data     = varargin{2};
    if (nargin ==3)
      header = varargin{3};
      x      = ( (0:header.Dimensions(2)-1) - (header.Dimensions(2)-1)/2 ) * header.PixelDimensions(2);
      y      = ( (0:header.Dimensions(1)-1) - (header.Dimensions(1)-1)/2 ) * header.PixelDimensions(1);
      z      = ( (0:header.Dimensions(3)-1) - (header.Dimensions(3)-1)/2 ) * header.PixelDimensions(3);
      % Convert mm to cm
      if strncmpi(header.VoxelUnits,'mm',2)==1
        x = x / 10;
        y = y / 10;
        z = z / 10;
      end
    elseif (nargin ==5)
      header = struct;
      x      = varargin{3};
      y      = varargin{4};
      z      = varargin{5};
    elseif (nargin ==6)
      header = varargin{3};
      x      = varargin{4};
      y      = varargin{5};
      z      = varargin{6};
    end
  end

  if (~ischar (filename))
    error ('analyze75write: `filename'' must be a string.');
  end
  
  %% Strip the filename of the extension
  fileextH = strfind (filename, '.hdr');
  fileextI = strfind (filename, '.img');
  if (~isempty (fileextH))
    fileprefix = filename(1:fileextH(end)-1);
  elseif (~isempty (fileextI))
    fileprefix = filename(1:fileextI(end)-1);
  else
    fileprefix = filename;
  end
  
  % Check the byteorder
  if (nargin == 6)
    if (isfield (header, 'ByteOrder')) &&  (any (strcmpi (header.ByteOrder, {'ieee-be', 'b'})))
      warning ('analyze75write: No support for big-endian. Please consider submitting a patch. Attempting to write as little-endian');
    end
  end
  header.ByteOrder = 'ieee-le';
  
  %% Rearrange the data
  data = permute(data,[2,1,3]);
  
  % Force uniform slice spacing
  if (max(unique(diff(z))) - min(unique(diff(z))) > 1e-4)
    warning ('analyze75write: Data slices must be equally spaced. Attempting to interpolate the data onto equally spaced slices.')
    [data,z] = interpslices(data,x,y,z);
  end

  % Check certain header fields
  header.PixelDimensions = single(10 * [x(2)-x(1),y(2)-y(1),z(2)-z(1)]);
  header.Dimensions      = int16([size(data),1]);
  header.HdrFileSize     = int32(348);
  header.VoxelUnits      = 'mm  ';
  header.GlobalMin       = int32(min(data(:)));
  header.GlobalMax       = int32(max(data(:)));
  header.FileName        = [fileprefix,'.hdr'];

  % Generate a string containing the coordinates of the first voxel (stored in the header for information only)
  header.Descriptor = repmat(' ',1,80);
  origintext = ['Coordinates of first voxel (mm):  ',num2str( 10* [x(1),y(1),z(1)] ,' %07.2f' )];
  header.Descriptor(1:numel(origintext)) = origintext;

  % Determine the type of data
  if (isa(data,'int16'))
    header.ImgDataType = 'DT_SIGNED_SHORT';
    header.BitDepth    = int16(16);
    DataTypeLabel      = int16(4);
    DataTypeString     = 'int16';
  elseif (isa(data,'int32'))
    header.ImgDataType = 'DT_SIGNED_INT';
    header.BitDepth    = int16(32);
    DataTypeLabel      = int16(8);
    DataTypeString     = 'int32';
  elseif (isa(data,'single'))
    header.ImgDataType = 'DT_FLOAT';
    header.BitDepth    = int16(32);
    DataTypeLabel      = int16(16);
    DataTypeString     = 'single';
  elseif (isa(data,'double'))
    header.ImgDataType = 'DT_DOUBLE';
    header.BitDepth    = int16(64);
    DataTypeLabel      = int16(64);
    DataTypeString     = 'double';
  end

  % Write the .hdr file
  fidH = fopen([fileprefix,'.hdr'],'w');

  fwrite(fidH,header.HdrFileSize,'int32',header.ByteOrder);         % HdrFileSize
  fwrite(fidH,repmat(' ',1,10),'char',header.ByteOrder);            % HdrDataType
  fwrite(fidH,repmat(' ',1,18),'char',header.ByteOrder);            % DatabaseName
  fwrite(fidH,zeros(1,1,'int32'),'int32',header.ByteOrder);         % Extents
  fwrite(fidH,zeros(1,1,'int16'),'int16',header.ByteOrder);         % SessionError
  fwrite(fidH,'r','char',header.ByteOrder);                         % Regular
  fwrite(fidH,repmat(' ',1,1),'char',header.ByteOrder);             % unused
  fwrite(fidH,zeros(1,1,'int16'),'int16',header.ByteOrder);         % unused
  fwrite(fidH,header.Dimensions(1),'int16',header.ByteOrder);       % Dimensions(1)
  fwrite(fidH,header.Dimensions(2),'int16',header.ByteOrder);       % Dimensions(2)
  fwrite(fidH,header.Dimensions(3),'int16',header.ByteOrder);       % Dimensions(3)
  fwrite(fidH,header.Dimensions(4),'int16',header.ByteOrder);       % Dimensions(4)
  fwrite(fidH,zeros(1,3,'int16'),'int16',header.ByteOrder);         % unused
  fwrite(fidH,header.VoxelUnits,'char',header.ByteOrder);           % VoxelUnits
  fwrite(fidH,repmat(' ',1,8),'char',header.ByteOrder);             % CalibrationUnits
  fwrite(fidH,zeros(1,1,'int16'),'int16',header.ByteOrder);         % unused
  fwrite(fidH,DataTypeLabel,'int16',header.ByteOrder);              % ImgDataType
  fwrite(fidH,header.BitDepth,'int16',header.ByteOrder);            % BitDepth
  fwrite(fidH,zeros(1,1,'int16'),'int16',header.ByteOrder);         % unused
  fwrite(fidH,zeros(1,1,'single'),'float',header.ByteOrder);        % unused
  fwrite(fidH,header.PixelDimensions(1),'float',header.ByteOrder);  % PixelDimensions(1)
  fwrite(fidH,header.PixelDimensions(2),'float',header.ByteOrder);  % PixelDimensions(2)
  fwrite(fidH,header.PixelDimensions(3),'float',header.ByteOrder);  % PixelDimensions(3)
  fwrite(fidH,zeros(1,4,'single'),'float',header.ByteOrder);        % unused
  fwrite(fidH,zeros(1,1,'single'),'float',header.ByteOrder);        % VoxelOffset
  fwrite(fidH,zeros(1,3,'single'),'float',header.ByteOrder);        % unused
  fwrite(fidH,zeros(1,1,'single'),'float',header.ByteOrder);        % CalibrationMax
  fwrite(fidH,zeros(1,1,'single'),'float',header.ByteOrder);        % CalibrationMin
  fwrite(fidH,zeros(1,1,'single'),'float',header.ByteOrder);        % Compressed
  fwrite(fidH,zeros(1,1,'single'),'float',header.ByteOrder);        % Verified
  fwrite(fidH,header.GlobalMax,'int32',header.ByteOrder);           % GlobalMax
  fwrite(fidH,header.GlobalMin,'int32',header.ByteOrder);           % GlobalMin
  fwrite(fidH,header.Descriptor,'char',header.ByteOrder);           % Descriptor
  fwrite(fidH,'none                    ','char',header.ByteOrder);  % AuxFile
  fwrite(fidH,repmat(' ',1,1),'char',header.ByteOrder);             % Orientation
  fwrite(fidH,repmat(' ',1,10),'char',header.ByteOrder);            % Originator
  fwrite(fidH,repmat(' ',1,10),'char',header.ByteOrder);            % Generated
  fwrite(fidH,repmat(' ',1,10),'char',header.ByteOrder);            % Scannumber

  if (isfield(header,'PatientID'))                                  % PatientID
    fwrite(fidH,sprintf('%10s',header.PatientID(1:min([10,numel(header.PatientID)]))),'char',header.ByteOrder);
  else
    fwrite(fidH,repmat(' ',1,10),'char',header.ByteOrder);
  end

  if (isfield(header,'ExposureDate'))                               % ExposureDate
    fwrite(fidH,sprintf('%10s',header.ExposureDate(1:min([10,numel(header.ExposureDate)]))),'char',header.ByteOrder);
  elseif isfield(header,'StudyDate')
    fwrite(fidH,sprintf('%10s',header.StudyDate(1:min([10,numel(header.StudyDate)]))),'char',header.ByteOrder);
  else
    fwrite(fidH,repmat(' ',1,10),'char',header.ByteOrder);
  end

  if (isfield(header,'ExposureTime'))                               % ExposureTime
    fwrite(fidH,sprintf('%10s',header.ExposureTime(1:min([10,numel(header.ExposureTime)]))),'char',header.ByteOrder);
  elseif isfield(header,'StudyTime')
    fwrite(fidH,sprintf('%10s',header.StudyTime(1:min([10,numel(header.StudyTime)]))),'char',header.ByteOrder);
  else
    fwrite(fidH,repmat(' ',1,10),'char',header.ByteOrder);
  end

  fwrite(fidH,repmat(' ',1,3),'char',header.ByteOrder);             % unused
  fwrite(fidH,zeros(1,1,'int32'),'int32',header.ByteOrder);         % Views
  fwrite(fidH,zeros(1,1,'int32'),'int32',header.ByteOrder);         % VolumesAdded
  fwrite(fidH,zeros(1,1,'int32'),'int32',header.ByteOrder);         % StartField
  fwrite(fidH,zeros(1,1,'int32'),'int32',header.ByteOrder);         % FieldSkip
  fwrite(fidH,zeros(1,1,'int32'),'int32',header.ByteOrder);         % OMax
  fwrite(fidH,zeros(1,1,'int32'),'int32',header.ByteOrder);         % OMin
  fwrite(fidH,zeros(1,1,'int32'),'int32',header.ByteOrder);         % SMax
  fwrite(fidH,zeros(1,1,'int32'),'int32',header.ByteOrder);         % SMin

  fclose(fidH);

  % Write the .img file
  fidI = fopen([fileprefix,'.img'],'w');
  fwrite(fidI,data,DataTypeString,header.ByteOrder);
  fclose(fidI);

end


function [datanew,znew] = interpslices(data,x,y,z)
  znew = z(1):min(diff(z)):z(end);
  datanew = zeros(numel(x),numel(y),numel(znew),class(data));
  for loopN = 1:numel(znew)
    datanew(:,:,loopN) = interpn(x,y,z,data,x,y,znew(loopN));
  end
end
