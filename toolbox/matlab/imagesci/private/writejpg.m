function writejpg(data, map, filename, varargin)
%WRITEJPG Write a JPG file to disk.
%   WRITEJPG(I,[],FILENAME) writes the grayscale image I
%   to the file specified by the string FILENAME.
%
%   WRITEJPG(RGB,[],FILENAME) writes the truecolor image
%   represented by the M-by-N-by-3 array RGB.
%
%   WRITEJPG(X,MAP,FILENAME) writes the indexed image X with
%   colormap MAP.  The resulting file will contain the equivalent
%   truecolor image.
%
%   WRITEJPG(...,'quality',VAL) uses VAL as the quality
%   factor.  VAL should be a scalar in the range [0, 100];
%   its default is 75.
%
%   WRITEJPG(...,'comment',COMMENTS) uses COMMENTS as the
%   column vector cell array or char matrix of comments to be
%   written to the file.  Each row in COMMENTS is written as a
%   separate comment.
%
%   WRITEJPG(...,'bitdepth',DEPTH) specifies the number of bits
%   that will be written for each sample.  DEPTH must be 8, 12,
%   or 16.  The default value of DEPTH is 8.
%
%   WRITEJPG(...,'mode',VAL) uses VAL as the compression mode.
%   MODE must be either 'lossy' for (8 or 12 bit depths) or 
%   'lossless' (for 8, 12, or 16 bits).  The default value of
%   MODE is 'lossy'.
  
%   Steven L. Eddins, August 1996
%   Copyright 1984-2001 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:04:59 $

  
% Input checking.
if (ndims(data) > 3)
    error('MATLAB:writejpg:tooManyDims', ...
          '%d-D data not supported for JPEG files', ndims(data));
end

if (~isempty(map) && ndims(data)>2)
    error('MATLAB:writejpg:tooManyDimsForIndexed', ...
          '%d-D indexed image data not supported for JPEG files', ndims(data));
end

ncomp = size(data,3);
if ((ncomp ~= 1) && (ncomp ~= 3))
    error('MATLAB:writejpg:wrongNumberOfComponents', ...
          'Data with %d components not supported for JPEG files', ncomp);
end

props = parse_args(varargin{:});

if ((props.bits > 12) && (ncomp > 1))
    error('MATLAB:writejpg:tooManyBitsForColor', ...
          'Only grayscale images supported with %d bit data.', props.bits)
end

if ((props.bits > 12) && (isequal(props.mode, 'lossy')))
    error('MATLAB:writejpg:tooManyBitsForLossy', ...
          'Lossy compression not supported for %d bit data.', props.bits)
end


% Convert indexed images to RGB.
maxval = (2 ^ (props.bits)) - 1;

if (~isempty(map))
  
    if (props.bits <= 8)
        colors = uint8(round(min(max(map,0),1) * maxval));
    else
        colors = uint16(round(min(max(map,0),1) * maxval));
    end
        
    
    % Handle logical, 8-bit, and 16-bit data together.
    %
    % Signed indices less than 0 cluster at index 1.
    % Indices larger than "maxval" cluster at index "maxval".
    if (~isa(data, 'double'))
        data = reshape(colors(double(data)+1,:), [size(data) 3]);
    else
        data = reshape(colors(data,:), [size(data) 3]);
    end
    
end


% Convert image data to UINT8/UINT16, if necessary.
if islogical(data)
  
    % Convert binary images to grayscale.
    mask = data;
    
    if (props.bits <= 8)
        data = uint8(data);
    else
        data = uint16(data);
    end
    
    data(mask) = maxval;
    
elseif ((~isa(data, 'uint8')) && (props.bits <= 8))
  
    % Convert 8-bit or smaller non-UINT8 samples to [0, maxval].
    data = uint8(round(maxval * double(data)));
   
elseif ((props.bits > 8) && (isa(data, 'double')))
  
    % Scale double data.
    data = uint16(round(maxval * double(data)));
    
elseif ((props.bits > 8) && (~isa(data, 'uint16')))
  
    % Don't scale if bits are greater than 8 for nondouble.
    % Do store all >8 bit/sample as UINT16.
    data = uint16(data);
    
end


% Write data to JPEG file.
if (props.bits <= 8)
  
    wjpg8c(data, filename, props);
    
elseif (props.bits <= 12)
  
    wjpg12c(data, filename, props);
    
else
  
    wjpg16c(data, filename, props);
    
end



function props = parse_args(varargin)
%PARSE_ARGS Parse additional input parameters.

% Set default values.
props.quality = 75;
props.comment = {};
props.bits = 8;
props.mode = 'lossy';

% Process param/value pairs
paramStrings = {'quality'
                'comment'
                'bitdepth'
                'mode'};

for k = 1:2:length(varargin)
  
    param = lower(varargin{k});
    if (~ischar(param))
        error('MATLAB:writejpg:badParameterName', ...
              'Parameter name must be a string');
    end
    
    idx = strmatch(param, paramStrings);
    
    if (isempty(idx))
        error('MATLAB:writejpg:unrecognizedParameter', ...
              'Unrecognized parameter name "%s"', param);
    elseif (length(idx) > 1)
        error('MATLAB:writejpg:ambiguousParameter', ...
              'Ambiguous parameter name "%s"', param);
    end
    
    param = deblank(paramStrings{idx});
    
    switch param
    case 'quality'
      
        quality = varargin{k+1};
        
	if (~isa(quality,'numeric'))
	    error('MATLAB:writejpg:badQualityValue', ...
                  '''Quality'' value must be numeric')
	end
        
        if ((quality < 0) || (quality > 100))
            error('MATLAB:writejpg:badQualityValue', ...
                  'Invalid value for ''Quality''');
        end
        
        props.quality = quality;
        
    case 'comment'
      
        comment = varargin{k+1};
        
        if (~ischar(comment) && ~iscellstr(comment))
            error('MATLAB:writejpg:badCommentValue', ...
                  ['''Comment'' value must be a column vector cell array of' ...
                 ' strings or a char matrix']);
        end
        
        % Convert the char matrix to a cell array
        props.comment = cellstr(comment);
        
    case 'bitdepth'
    
        bits = varargin{k+1};
        
        if (~isa(bits,'numeric'))
	    error('MATLAB:writejpg:badBitDepth', ...
                  '''BitDepth'' value must be numeric')
	end
        
        if (~any(bits == [8 12 16]))
            error('MATLAB:writejpg:badBitDepth', ...
                  '''BitDepth'' value must be 8, 12, or 16');
        end
        
        props.bits = bits;
        
    case 'mode'
        
        mode = lower(varargin{k+1});
        
        if ((~ischar(mode)) || ...
            ((~isequal(mode, 'lossy')) && (~isequal(mode, 'lossless'))))
          
            error('MATLAB:writejpg:badMode', ...
                  '''Mode'' must be ''Lossy'' or ''Lossless''')
        
        end
        
        props.mode = mode;
     
    end
    
end

