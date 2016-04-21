function pixel_cells = dicom_encode_pixel_cells(X, map)
%DICOM_ENCODE_PIXEL_CELLS   Convert an image to pixel cells.
%   PIXCELLS = DICOM_ENCODE_PIXEL_CELLS(X, MAP) convert the image X with
%   colormap MAP to a sequence of DICOM pixel cells.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.3 $  $Date: 2003/08/01 18:10:38 $


% Verify just one frame.
if (size(X, 4) > 1)
    
    error('Images:dicom_encode_pixel_cells:tooManyFrames', 'Only one frame can be encoded at one time.')
    
end

% Images are stored across then down.  If there are multiple samples,
% keep all samples for each pixel contiguously stored.
X = permute(X, [3 2 1]);

% Convert to correct output type.
if (islogical(X))

    dicom_warn('Logical data will be scaled to fit the range [0, 255].');
    
    tmp = uint8(X);
    tmp(X) = 255;
    
    X = tmp;
    
elseif (isa(X, 'double'))
   
    if (isempty(map))
        
        % RGB or Grayscale.
        X = uint16(65535 * X);
        
    else
       
        if (size(X, 1) == 1)
            
            % Indexed.
            X = uint16(X - 1);
            
        elseif (size(X, 1) == 4)
            
            % RGBA
            X(1:3, :, :) = X(1:3, :, :) * 65535;
            X(4, :, :)   = X(4, :, :) - 1;
            X = uint16(X);
            
        end
            
        
    end
    
end
    
pixel_cells = X(:);
