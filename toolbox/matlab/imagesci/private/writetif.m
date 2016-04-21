function writetif(data, map, filename, varargin)
%WRITETIF Write a TIF file to disk.
%   WRITETIF(X,MAP,FILENAME) writes the indexed image X,MAP
%   to the file specified by the string FILENAME.
%
%   WRITETIF(GRAY,[],FILENAME) writes the grayscale image GRAY
%   to the file.
%
%   WRITETIF(RGB,[],FILENAME) writes the truecolor image
%   represented by the M-by-N-by-3 array RGB.
%
%   WRITETIF(..., 'compression', COMP) uses the compression
%   type indicated by the string COMP.  COMP can be 'packbits',
%   'ccitt', 'fax3', 'fax4', or 'none'.  'ccitt', 'fax3', and 'fax4'
%   are allowed for logical inputs only.  'packbits' is the default.
%
%   WRITETIF(..., 'description', DES) writes the string contained
%   in DES to the TIFF file as an ImageDescription tag.
%
%   WRITETIF(..., 'resolution', XYRes) uses the scalar in XYRes
%   for the XResolution and YResolution tags.
%
%   WRITETIF(..., 'colorspace', CS) writes a TIFF file using the
%   specified colorspace, either 'rgb', 'icclab', or 'cielab'.  The input
%   image array must be M-by-N-by-3.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:01:43 $

if (ndims(data) > 3)
    error('MATLAB:writetif:tooManyDims', ...
          '%d-D data not supported for TIFF files', ndims(data));
end

% 1 component or 3 components?
ncomp = size(data,3);
if ((ncomp ~= 1) && (ncomp ~= 3) && (ncomp ~= 4))
    error(sprintf('Data with %d components not supported for TIFF files', ...
            ncomp));
end

description = '';
compression = 'packbits';
resolution = 72;
writemode = 1;
colorspace = 'rgb';

if (islogical(data) && (ndims(data) == 2) && isempty(map))
    compression = 'ccitt';
end

% Process param/value pairs
paramStrings = ['compression'
                'description'
                'resolution '
                'writemode  '
                'colorspace '];
    
for k = 1:2:length(varargin)
    param = lower(varargin{k});
    if (~ischar(param))
        error('MATLAB:writetif:badParameterName', ...
               'Parameter name must be a string');
    end
    idx = strmatch(param, paramStrings);
    if (isempty(idx))
        error('MATLAB:writetif:unrecognizedParameter', ...
              'Unrecognized parameter name "%s"', param);
    elseif (length(idx) > 1)
        error('MATLAB:writetif:ambiguousParameter', ...
              'Ambiguous parameter name "%s"', param);
    end
    
    param = deblank(paramStrings(idx,:));
    
    switch param
    case 'compression'
        compression = varargin{k+1};
        if (~ischar(compression))
            error('MATLAB:writetif:badCompression', ...
                  'COMPRESSION must be a string');
        end
        
    case 'description'
        description = varargin{k+1};
        if (~ischar(description))
            error('MATLAB:writetif:badDescription', ...
                  'DESCRIPTION must be a string');
        end
        
    case 'resolution'
        resolution = varargin{k+1};
        
    case 'writemode'
        switch lower(varargin{k+1})
            case 'overwrite'
                writemode = 1;
                
            case 'append'
                writemode = 0;
                
            otherwise
                error('MATLAB:writetif:badWriteMode', ...
                      'WRITEMODE must be ''overwrite'' or ''append''.');
        end
        
    case 'colorspace'
        colorspace = varargin{k+1};
        if ~ischar(colorspace)
            eid = 'MATLAB:imwrite:colorspaceInvalidClass';
            error(eid,'%s','COLORSPACE must be a string.');
        end
        colorspace = lower(colorspace);
        if ~ismember(colorspace, {'rgb', 'cielab', 'icclab'})
            eid = 'MATLAB:imwrite:colorspaceUnrecognizedString';
            error(eid,'%s',...
                  'COLORSPACE must be one of these strings: ''rgb'', ''cielab'', or ''icclab''.');
        end

        if (ndims(data) ~= 3) && (size(data, 3) ~= 3)
            wid = 'MATLAB:imwrite:ignoredColorspaceInput';
            msg = 'Colorspace parameter ignored since the image array is not M-by-N-by-3.';
            warning(wid,'%s',msg);
        end
    end
end

if (ndims(data) == 3) && (size(data,3) == 3) && ...
        (isequal(colorspace, 'cielab') || isequal(colorspace, 'icclab'))
    if isa(data, 'double')
        % Convert to 8-bit ICCLAB.
        data(:,:,1) = round(data(:,:,1) * 255 / 100);
        data(:,:,2:3) = round(data(:,:,2:3) + 128);
        data = uint8(data);
    end
    
    if isequal(colorspace, 'cielab')
        % Convert to "munged" cielab values before writing them with
        % wtifc.
        data = icclab2cielab(data);
    end
end

if ~(isa(data, 'logical') || isa(data, 'uint8') || isa(data, 'uint16'))
    if (~isempty(map))
        data = uint8(data - 1);
    else
        data = min(1, max(0, data));    
        data = uint8(round(255 * data));
    end
end

if (~isempty(map) && ~isa(map,'uint16'))
    map = uint16(round(65535 * map));
end

% Now that everything else is verified, check that it's possible to
% open a file here.  If it's not, fail.  If it is, this call to FOPEN
% will either create a new file or open an existing file.  Let the TIFF C
% code decide whether to truncate it.
fid = fopen(filename, 'a');
if (fid < 0)
    error('MATLAB:writetif:fileOpen', ...
          'Couldn''t open ''%s'' for writing.', filename);
else
    fclose(fid);
end

wtifc(data, map, filename, compression, description, resolution, writemode, colorspace);
