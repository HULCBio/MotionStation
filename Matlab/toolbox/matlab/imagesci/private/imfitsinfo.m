function [metadata,msg] = imfitsinfo(filename)
%IMFITSINFO Information about a JPEG file.
%   [INFO,MSG] = IMFITSINFO(FILENAME) returns a structure containing
%   information about the FITS file specified by the string
%   FILENAME.  
%
%   If any error condition is encountered, such as an error opening
%   the file, MSG will contain a string describing the error and
%   INFO will be empty.  Otherwise, MSG will be empty.
%
%   See also IMREAD, IMWRITE, IMFINFO.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 03:00:17 $

% Fix the position of IMFINFO fields.
metadata.Filename = [];
metadata.FileModDate = [];
metadata.FileSize = [];
metadata.Format = 'fits';
metadata.FormatVersion = '';
metadata.Width = [];
metadata.Height = [];
metadata.BitDepth = [];
metadata.ColorType = [];

try
    metadata_file = fitsinfo(filename);
    msg = [];
catch
    metadata = [];
    msg = lasterr;
    return
end

if (isempty(metadata_file))
    metadata = [];
    return
end

% Add fields from FITSINFO.
fnames = fieldnames(metadata_file);
for p = 1:numel(fnames)
    metadata.(fnames{p}) = metadata_file.(fnames{p});
end

%
% Set IMFINFO-specific fields based on fields in the metadata.
%

% Get the keywords from the metadata.
keywords = metadata_file.PrimaryData.Keywords(:,1);

% NAXIS is the number of axes in the dataset.  The size of the first
% axis is then umber of rows; if the second axis exists, it is for the
% columns.
idx = find(strcmp('NAXIS', keywords));

% Height and width.
naxis = metadata_file.PrimaryData.Keywords{idx,2};
if (naxis == 0)

    metadata.Width = 0;
    metadata.Height = 0;
    
else
    
    
    if (naxis == 1)
    
        % 1-D data (e.g., spectral data) is a row vector.
        idx = find(strcmp('NAXIS1', keywords));
        metadata.Width = metadata_file.PrimaryData.Keywords{idx,2};
        metadata.Height = 1;
        
    else
        
        % In 2-D data, the first dimension is the number of columns.
        idx = find(strcmp('NAXIS1', keywords));
        metadata.Width = metadata_file.PrimaryData.Keywords{idx,2};
        
        idx = find(strcmp('NAXIS2', keywords));
        metadata.Height = metadata_file.PrimaryData.Keywords{idx,2};
        
    end
    
end

% Bit depth.
idx = find(strcmp('BITPIX', keywords));
metadata.BitDepth = abs(metadata_file.PrimaryData.Keywords{idx,2});

% Color type.
if (naxis >= 3)

    idx = find(strcmp('NAXIS3', keywords));
    nsamples = metadata_file.PrimaryData.Keywords{idx,2};
    
    if (nsamples == 1)
        
        metadata.ColorType = 'grayscale';
        
    elseif (nsamples == 3)
        
        metadata.ColorType = 'truecolor';
        
    else
        
        metadata.ColorType = 'unknown';
        
    end

else
    
    metadata.ColorType = 'grayscale';
    
end
