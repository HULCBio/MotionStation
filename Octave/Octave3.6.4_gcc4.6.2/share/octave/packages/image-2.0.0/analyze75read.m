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
%% @deftypefn {Function File} {@var{image} =} analyze75read (@var{filename})
%% @deftypefnx {Function File} {@var{image} =} analyze75read (@var{header})
%% Read image data of an Analyze 7.5 file.
%%
%% @var{filename} must be the path for an Analyze 7.5 file or the path for a
%% directory with a single .hdr file can be specified. Alternatively, the file
%% @var{header} can be specified as returned by @code{analyze75info}.
%%
%% @seealso{analyze75info, analyze75write}
%% @end deftypefn

function data = analyze75read (filename);

  if (nargin ~= 1)
    print_usage;
  elseif (isstruct (filename))
    if (~isfield (filename, 'Filename'))
      error ('analyze75read: structure given does not have a `Filename'' field.');
    else
      header   = filename;
      filename = filename.Filename;
    end
  elseif (~ischar (filename))
    error ('analyze75read: `filename'' must be either a string or a structure.');
  end

  fileprefix = analyze75filename (filename);

  if (~exist ('header', 'var'))
    header = analyze75info ([fileprefix, '.hdr']);
  end

  %% finally start reading the actual file
  [fidI, err] = fopen ([fileprefix, '.img']);
  if (fidI < 0)
    error ('analyze75read: unable to fopen `%s'': %s', [fileprefix, '.img'], err);
  end

  if (strcmp (header.ImgDataType, 'DT_SIGNED_SHORT'));
    datatype = 'int16';
  elseif (strcmp (header.ImgDataType, 'DT_SIGNED_INT'));
    datatype = 'int32';
  elseif (strcmp (header.ImgDataType, 'DT_FLOAT'));
    datatype = 'single';
  elseif (strcmp (header.ImgDataType, 'DT_DOUBLE'));
    datatype = 'double';
  end

  data    = zeros (header.Dimensions, datatype);
  data(:) = fread (fidI, datatype, header.ByteOrder);

  fclose (fidI);

  %% Rearrange the data
  data = permute (data, [2,1,3]);
end
