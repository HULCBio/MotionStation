%% Contrast Enhancement Techniques
% The Image Processing Toolbox contains several image enhancement 
% routines. Three functions are particularly suitable for contrast 
% enhancement: |imadjust|, |histeq|, and |adapthisteq|.
% This demo compares their use for enhancing grayscale and
% truecolor images.
%
% Copyright 1993-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/05/03 17:53:38 $


%% Step 1: Load images
% Read in two grayscale images:  |pout.tif| and |tire.tif|. Also read in
% an indexed RGB image: |shadow.tif|.

pout = imread('pout.tif');
tire = imread('tire.tif');
[X map] = imread('shadow.tif');
shadow = ind2rgb(X,map); % convert to truecolor

%% Step 2: Resize images
% To make the image comparison easier, resize the images to have the
% same width.  Preserve their aspect ratios by scaling their heights.

width = 210;
images = {pout, tire, shadow};

for k = 1:3
  dim = size(images{k});
  images{k} = imresize(images{k},[width*dim(1)/dim(2) width],'bicubic');
end

pout = images{1};
tire = images{2};
shadow = images{3};

%% Step 3: Enhance grayscale images
% Using the default settings, compare the effectiveness of the 
% following three techniques:
%
% * *|imadjust|* increases the contrast of the image by mapping the values 
%              of the input intensity image to new values such that, 
%              by default, 1% of the data is saturated at low and high 
%              intensities of the input data.
% * *|histeq|* performs histogram equalization. It enhances the contrast 
%            of images by transforming the values in an intensity image
%            so that the histogram of the output image
%            approximately matches a specified histogram (uniform distribution
%            by default).
% * *|adapthisteq|* performs contrast-limited adaptive histogram equalization.
%            Unlike |histeq|, it operates on small data regions (tiles)
%            rather than the entire image. Each tile's contrast is 
%            enhanced so that the histogram of each output region approximately
%            matches the specified histogram (uniform distribution by default).
%            The contrast enhancement can be limited in order to avoid
%            amplifying the noise which might be present in the image.
%

pout_imadjust = imadjust(pout);
pout_histeq = histeq(pout);
pout_adapthisteq = adapthisteq(pout);

imshow(pout);
title('Original');

figure, imshow(pout_imadjust);
title('Imadjust');

%%

figure, imshow(pout_histeq);
title('Histeq');

figure, imshow(pout_adapthisteq);
title('Adapthisteq');

%%

tire_imadjust = imadjust(tire);
tire_histeq = histeq(tire);
tire_adapthisteq = adapthisteq(tire);

figure, imshow(tire);
title('Original');

figure, imshow(tire_imadjust);
title('Imadjust');

%%

figure, imshow(tire_histeq);
title('Histeq');

figure, imshow(tire_adapthisteq);
title('Adapthisteq');

%%
% Notice that |imadjust| had little effect on the image of the
% tire, but it caused a drastic change in the case of pout.
% Plotting the histograms of |pout.tif| and |tire.tif| reveals that most 
% of the pixels in the first image are concentrated in the center of
% the histogram, while in the case of |tire.tif|, the values are already
% spread out between the minimum of 0 and maximum of 255 thus preventing 
% |imadjust| from being effective in adjusting the contrast of the image.

%%
figure, imhist(pout), title('pout.tif');
figure, imhist(tire), title('tire.tif');

%%
% Histogram equalization, on the other hand, substantially changes 
% both images. Many of the previously hidden features are exposed, 
% especially the debris particles on the tire. Unfortunately, at the same 
% time, the enhancement over-saturates several areas of both images.
% Notice how the center of the tire, part of the child's face,
% and the jacket became washed out.
%
% Concentrating on the image of the tire, it would be
% preferable for the center of the wheel to stay at about the same
% brightness while enhancing the contrast in other areas of the image.
% In order for that to happen, a different transformation would have to
% be applied to different portions of the image. The Contrast-Limited Adaptive 
% Histogram Equalization technique, implemented in |adapthisteq|, can
% accomplish this.  The algorithm analyzes portions of the image and computes 
% the appropriate transformations. A limit on the level of contrast
% enhancement can also be set, thus preventing the over-saturation caused 
% by the basic histogram equalization method of |histeq|. This is the 
% most sophisticated technique in this demonstration.

%% Step 4: Enhance color images
% Contrast enhancement of color images is typically done by transforming an
% image to a color space that has image intensity as one of its components.
% One such color space is L*a*b*. Use color transform functions to convert 
% the image from RGB to L*a*b* color space, and then work on 
% the luminosity layer 'L*' of the image. Manipulating luminosity affects
% the intensity of the pixels, while preserving the original colors.

srgb2lab = makecform('srgb2lab');
lab2srgb = makecform('lab2srgb');

shadow_lab = applycform(shadow, srgb2lab); % convert to L*a*b*

% the values of luminosity can span a range from 0 to 100; scale them
% to [0 1] range (appropriate for MATLAB intensity images of class double) 
% before applying the three contrast enhancement techniques
max_luminosity = 100;
L = shadow_lab(:,:,1)/max_luminosity;

% replace the luminosity layer with the processed data and then convert
% the image back to the RGB colorspace
shadow_imadjust = shadow_lab;
shadow_imadjust(:,:,1) = imadjust(L)*max_luminosity;
shadow_imadjust = applycform(shadow_imadjust, lab2srgb);

shadow_histeq = shadow_lab;
shadow_histeq(:,:,1) = histeq(L)*max_luminosity;
shadow_histeq = applycform(shadow_histeq, lab2srgb);

shadow_adapthisteq = shadow_lab;
shadow_adapthisteq(:,:,1) = adapthisteq(L)*max_luminosity;
shadow_adapthisteq = applycform(shadow_adapthisteq, lab2srgb);

figure, imshow(shadow);
title('Original');

figure, imshow(shadow_imadjust);
title('Imadjust');

%%

figure, imshow(shadow_histeq);
title('Histeq');

figure, imshow(shadow_adapthisteq);
title('Adapthisteq');
