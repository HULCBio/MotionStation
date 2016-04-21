function [out, file] = dicom_xform_image(in, info, raw, file)
%DICOM_XFORM_IMAGE   Reshape images, apply colorspace transformations.
%   OUT = DICOM_XFORM_IMAGE(IN, INFO, RAW) reshapes and transforms the
%   pixels in IN according to the information in INFO.  When RAW is 0,
%   all applicable transformations will be applied.  When RAW is 1, the
%   pixel array is reshaped only; colorspace transformations are not
%   applied and pixels are not rescaled to fill the dynamic range.
%
%   Note: CMYK and YCbCr images are converted to RGB.  Grayscale images
%   where 0 is white (MONOCHROME1) are converted to images where 0 is
%   black.  No other colorspaces are converted.
%
%   Note: Certain conditions will cause pixel-level transformations
%   (i.e., colorspace conversions and scaling) not to occur.  When images
%   contain signed data, these transformations are not performed.  If
%   INFO does not Photometric Interpretation, data is rescaled as
%   appropriate but colorspace transformations do not happen.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2003/08/23 05:54:03 $


%
% Expand 4:2:2 YCbCr images.
%

if (isfield(info, 'PhotometricInterpretation'))
    
    % Make sure 4:2:2 sampling is stored YYbrYYbrYYbr....
    
    switch (info.PhotometricInterpretation)
    case {'YBR_FULL_422', 'YBR_PARTIAL_422'}
        
        if ((isfield(info, 'PlanarConfiguration')) && ...
            (info.PlanarConfiguration ~= 0))
            
            msg = sprintf(['Invalid planar configuration value of %d' ...
                           ' in "%s".\nNo image transformations performed.'],...
                          info.PlanarConfiguration, info.Filename);
            
            file = dicom_warn(msg, file);
            return;
            
        end
        
    end
    
end


%
% Reshape images.
%

tmp = reshape_pixels(in, info);

if (raw)

    % User specified no transformations.
    
    out = tmp;
    return
    
end

%
% Convert colorspaces and rescale ranges.
%

% Don't assume a particular photometric interpretation or pixel rep.
if (~isfield(info, 'PhotometricInterpretation'))
   
    msg = sprintf(['Photometric information missing in "%s".\n' ...
                   'No pixel transformations performed.'], info.Filename);
    file = dicom_warn(msg, file);
    
    out = tmp;
    return;
    
end

% Don't convert if no pixel representation data.
if (~isfield(info, 'PixelRepresentation'))
    
    msg = sprintf(['Pixel representation information missing in "%s".\n' ...
                   'No rescaling performed.'], info.Filename);
    file = dicom_warn(msg, file);
    
    out = tmp;
    return
    
else
    
    pix_rep = info.PixelRepresentation;

end

% Don't convert if signed.
if (pix_rep == 1)
    
    msg = sprintf('Signed image data in "%s" will not be converted or scaled.', ...
                  info.Filename);

    file = dicom_warn(msg, file);
    
    out = tmp;
    return
    
end

% Ready to convert.

switch info.PhotometricInterpretation
case {'MONOCHROME1'}
    
    % White is 0:  Rescale and switch to black is 0.
    
    if (rem(info.BitsStored, 8) ~= 0)
        tmp = rescale_pixels(tmp, info);
    end

    out = imcomplement(tmp);
    
case {'MONOCHROME2'}
    
    % Black is 0:  Rescale.
    
    if (rem(info.BitsStored, 8) ~= 0)
        out = rescale_pixels(tmp, info);
    else
        out = tmp;
    end

case {'PALETTE COLOR'}
    
    % Indexed image:  Don't rescale or convert.
    out = tmp;
    
case {'RGB'}
    
    % RGB:  Rescale.
    
    if (rem(info.BitsStored, 8) ~= 0)
        out = rescale_pixels(tmp, info);
    else
        out = tmp;
    end

case {'HSV'}
    
    % In comp.protocols.DICOM, David Clunie wrote:
    %
    % There is no real definition for the photometric interpretation
    % of HSV in DICOM. It isn't used in any modality specific image
    % objects, so the issue has never come up. One could use it for
    % an image of the Secondary Capture SOP class, but nobody else
    % would be able to display it.
    
    msg = sprintf(['HSV storage is undefined in the DICOM standard.\n' ...
                   'HSV data in "%s" will not be converted to RGB.'], ...
                  info.Filename);
    
    file = dicom_warn(msg, file);
    return;
    
case {'ARGB'}
    
    % RGB + Alpha:  Rescale RGB; don't change alpha.
    
    if (rem(info.BitsStored, 8) ~= 0)
        out(:, :, 1:3, :) = rescale_pixels(tmp(:, :, 1:3, :), info);
    else
        out = tmp;
    end
    
case {'CMYK'}
    
    % CMYK: Rescale and convert.
    
    if (rem(info.BitsStored, 8) ~= 0)
        tmp = rescale_pixels(tmp, info);
    end
    
    out = cmyk2rgb(tmp);

case {'YBR_FULL', 'YBR_FULL_422'}
    
    % YCbCr full:  Convert and rescale in one step.
    out = ybr2rgb(tmp, 'full', info.BitsStored);
    
case {'YBR_PARTIAL_422'}
    
    % YCbCr partial (4:2:2):  Convert and rescale in one step.
    out = ybr2rgb(tmp, 'partial', info.BitsStored);
    
end






%%%
%%% Function reshape_pixels
%%%

function out = reshape_pixels(in, info)
%RESHAPE_PIXELS   Reshape a vector of pixel cells to the correct dimensions

% SamplesPerPixel is a required field for anything implementing the Image
% Pixel Module.  ACR-NEMA files often didn't have this, though.

% Determine SamplesPerPixel.
if (~isfield(info, 'SamplesPerPixel'))
    
    if (isfield(info, 'PhotometricInterpretation'))
    
        switch (info.PhotometricInterpretation)
        case {'MONOCHROME1', 'MONOCHROME2', 'PALETTE COLOR'}
            
            info.SamplesPerPixel = 1;
            
        case {'RGB', 'HSV', 'YBR_FULL'}

            info.SamplesPerPixel = 3;
            
        case {'YBR_FULL_422', 'YBR_PARTIAL_422'}

            % These formats have 3 samples per pixel.  Two Y values are
            % stored followed by one Cb and one Cr value.  The Cb and Cr
            % values are sampled at the location of the first of the two
            % Y values.  For each row of pixels, the first Cb and Cr
            % samples are at the location of the first Y sample.
            %
            % See PS 3.3-2000 Sec. C.7.6.3.1.2.
            
            info.SamplesPerPixel = 3;
            
            
            % Upsample the Cb and Cr components.
            
            % Get like components together:
            % tmp = [odd_column_y; even_column_y; Cb; Cr]
            
            tmp = reshape(in, [4 length(in)/4]);

            % Replicate Cb and Cr components.
            CbCr = repmat(tmp(3:4,:), [2 1]);
            CbCr = reshape(CbCr(:), [2 size(CbCr, 2)]);
            
            % Recompose pixel stream with new Cb and Cr samples.
            Y_vals = tmp(1:2,:);
            tmp = [Y_vals(:)'; CbCr];
            in = tmp(:);

        case {'ARGB', 'CMYK'}
            
            info.SamplesPerPixel = 4;
            
        end
            
    elseif (isfield(info, 'RedPaletteColorLookupTableData'))
        
        info.SamplesPerPixel = 3;
        
    else
        
        % Assume 1 sample per pixel.
        info.SamplesPerPixel = 1;
        
    end
    
    
end

%
% Reshape data.
%

samples = info.SamplesPerPixel;
num_elts = numel(in);
frames = num_elts/(info.Height * info.Width * samples);

% If a format uses IMREAD to decompress encapsultated data, then the data
% is correctly shaped.  Otherwise the data is in a vector.

if (num_elts == length(in))
    
    % True-color and ARGB images can be stored with contiguous pixel samples
    % (e.g., RR...GG...BB...) or with samples interleaved by pixel (e.g.,
    % RGBRGB...).  Multisample RLE-decompressed images always are
    % interleaved.
    
    if (((isfield(info, 'TransferSyntaxUID')) && ...
         (isequal(info.TransferSyntaxUID, '1.2.840.10008.1.2.5')) && ...
         (samples > 1)) || ...
        ((isfield(info, 'PlanarConfiguration')) && ...
         (info.PlanarConfiguration == 0)))
        
        % Sample values for first pixel are followed by the sample values for
        % the next (e.g., RGBRGB...).
        
        % Make samples contiguous (for all frames).
        tmp = reshape(in, [samples, num_elts/samples]);
        
        % Separate by frames.
        tmp = reshape(tmp, [samples, num_elts/(samples * frames), frames]);
        
        % Convert to stream of contiguous pixel samples (by frame).
        tmp = permute(tmp, [2 1 3]);
        tmp = tmp(:);        
    
    else
        
        tmp = in;
        
    end
    

    % Reshape to final MATLAB form.
    
    tmp = reshape(tmp, [info.Width info.Height samples frames]);
    out = permute(tmp, [2 1 3 4]);
   
else
    
    out = in;
    
end
    


%%%
%%% Function rescale_pixels
%%%

function out = rescale_pixels(in, info)
% Rescale pixel values to span the dynamic range

% Special case for binary images.
if (info.BitsStored == 1)
    
    out = logical(in);
    return
    
end


% Shift the pixels so that HighBit is most significant bit.

switch (class(in))
case 'uint8'
    amt = 8 - info.BitsStored;
case 'uint16'
    amt = 16 - info.BitsStored;
case 'uint32'
    amt = 32 - info.BitsStored;
end

out = bitshift(in, amt);


% Fill in least significant bits with higher-order bits.
out = bitor(out, bitshift(out, -(info.BitsStored)));



%%%
%%% Function cmyk2rgb
%%%

function rgb = cmyk2rgb(cmyk)
% Convert CMYK images to RGB

tmp = cmyk;
tmp(:,:,4,:) = [];
tmp(:) = 0;

black_comp = imcomplement(cmyk(:,:,4,:));
    
for p = 1:size(cmyk, 4)
    
    % For components C, M, and Y find:
    %
    %   min(maxint, component * (maxint - black) + black)
    %
    % Because IMMULTIPLY and IMLINCOMB truncate on overflow, it
    % is possible to skip the MIN computation.
    
    % Cyan.
    tmp(:,:,1,p) = imadd(immultiply(cmyk(:,:,1,p), ...
                                    black_comp(:,:,p)), ...
                         cmyk(:,:,4,p));
    
    % Magenta.
    tmp(:,:,2,p) = imadd(immultiply(cmyk(:,:,2,p), ...
                                    black_comp(:,:,p)), ...
                         cmyk(:,:,4,p));
    
    % Yellow.
    tmp(:,:,3,p) = imadd(immultiply(cmyk(:,:,3,p), ...
                                    black_comp(:,:,p)), ...
                         cmyk(:,:,4,p));
    
end

% CMY -> RGB.
rgb = imcomplement(tmp);



%%%
%%% Function ybr2rgb
%%%

function out = ybr2rgb(in, format, bits)
% Convert YCbCr images to RGB and rescale values to fill range

% 4:2:2 data should have already been upsampled to 4:4:4.
%
% For the RGB -> YCbCr conversion matrices see PS 3.3-2000 Sec C.7.6.3.1.2.


% Rescale data to [0, 255] and convert to double.
switch (class(in))
case {'uint8'}

    if (rem(bits, 8) == 0)
        tmp = double(in);
    else
        tmp = double(bitshift(in, (8 - bits)));
    end
        
case 'uint16'

    if (rem(bits, 8) == 0)
        tmp = double(in)/(2^8 + 1);
    else
        tmp = double(bitshift(in, (16 - bits)));
        tmp = tmp/(2^8 + 1);
    end
        
case 'uint32'

    if (rem(bits, 8) == 0)
        tmp = double(in)/(2^24 + 1);
    else
        tmp = double(bitshift(in, (32 - bits)));
        tmp = tmp/(2^24 + 1);
    end
        
end

switch (format)
case 'full'
    
    scale = [0 128 128]';

    RGB = [ 0.2990  0.5870  0.1140;
           -0.1687 -0.3313  0.5000;
            0.5000 -0.4187 -0.0813];

case 'partial'
    
    scale = [16 128 128]';
    
    RGB = [ 0.2568  0.5041  0.0979;
           -0.1482 -0.2910  0.4392;
            0.4392 -0.3678 -0.0714];

end
    
Ybr = inv(RGB);

% Convert values.

for p = 1:size(in, 4)

    tmp(:,:,1,p) = tmp(:,:,1,p) - scale(1);
    tmp(:,:,2,p) = tmp(:,:,2,p) - scale(2);
    tmp(:,:,3,p) = tmp(:,:,3,p) - scale(3);
    
    out(:,:,1,p) = Ybr(1,1) * tmp(:,:,1,p) + Ybr(1,2) * tmp(:,:,2,p) + ...
        Ybr(1,3) * tmp(:,:,3,p);
    out(:,:,2,p) = Ybr(2,1) * tmp(:,:,1,p) + Ybr(2,2) * tmp(:,:,2,p) + ...
        Ybr(2,3) * tmp(:,:,3,p);
    out(:,:,3,p) = Ybr(3,1) * tmp(:,:,1,p) + Ybr(3,2) * tmp(:,:,2,p) + ...
        Ybr(3,3) * tmp(:,:,3,p);
    
end 

% Convert to original type.
switch (class(in))
case {'uint8'}
    out = uint8(out);
case 'uint16'
    out = uint16(out * (2^8 + 1));
case 'uint32'
    out = uint32(out * (2^24 + 1));
end
