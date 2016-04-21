% Image Processing Toolbox
% Version 4.2 (R14) 05-May-2004
%
% Image display.
%   colorbar       - Display colorbar (MATLAB Toolbox).
%   getimage       - Get image data from axes.
%   image          - Create and display image object (MATLAB Toolbox).
%   imagesc        - Scale data and display as image (MATLAB Toolbox).
%   immovie        - Make movie from multiframe image.
%   imshow         - Display image in Handle Graphics figure.
%   imview         - Display image in the image viewer.
%   montage        - Display multiple image frames as rectangular montage.
%   movie          - Play recorded movie frames (MATLAB Toolbox).
%   subimage       - Display multiple images in single figure.
%   truesize       - Adjust display size of image.
%   warp           - Display image as texture-mapped surface.
%
% Image file I/O.
%   dicominfo      - Read metadata from a DICOM message.
%   dicomread      - Read a DICOM image.
%   dicomuid       - Generate DICOM unique identifier.
%   dicomwrite     - Write a DICOM image.
%   dicom-dict.txt - Text file containing DICOM data dictionary.
%   imfinfo        - Return information about image file (MATLAB Toolbox).
%   imread         - Read image file (MATLAB Toolbox).
%   imwrite        - Write image file (MATLAB Toolbox).
%
% Image arithmetic.
%   imabsdiff      - Compute absolute difference of two images.
%   imadd          - Add two images, or add constant to image.
%   imcomplement   - Complement image.
%   imdivide       - Divide two images, or divide image by constant.
%   imlincomb      - Compute linear combination of images.
%   immultiply     - Multiply two images, or multiply image by constant.
%   imsubtract     - Subtract two images, or subtract constant from image.
%   ippl           - Check for presence of IPPL.
%
% Geometric transformations.
%   checkerboard   - Create checkerboard image.
%   findbounds     - Find output bounds for geometric transformation.
%   fliptform      - Flip the input and output roles of a TFORM struct.
%   imcrop         - Crop image.
%   imresize       - Resize image.
%   imrotate       - Rotate image.
%   imtransform    - Apply geometric transformation to image.
%   makeresampler  - Create resampler structure.
%   maketform      - Create geometric transformation structure (TFORM).
%   tformarray     - Apply geometric transformation to N-D array.
%   tformfwd       - Apply forward geometric transformation.
%   tforminv       - Apply inverse geometric transformation.
%
% Image registration.
%   cpstruct2pairs - Convert CPSTRUCT to valid pairs of control points.
%   cp2tform       - Infer geometric transformation from control point pairs.
%   cpcorr         - Tune control point locations using cross-correlation. 
%   cpselect       - Control point selection tool.
%   normxcorr2     - Normalized two-dimensional cross-correlation.
%
% Pixel values and statistics.
%   corr2          - Compute 2-D correlation coefficient.
%   imcontour      - Create contour plot of image data.
%   imhist         - Display histogram of image data.
%   impixel        - Determine pixel color values.
%   improfile      - Compute pixel-value cross-sections along line segments.
%   mean2          - Compute mean of matrix elements.
%   pixval         - Display information about image pixels.
%   regionprops    - Measure properties of image regions.
%   std2           - Compute standard deviation of matrix elements.
%
% Image analysis.
%   bwboundaries    - Trace region boundaries in binary image.
%   bwtraceboundary - Trace object in binary image.
%   edge            - Find edges in intensity image.
%   qtdecomp        - Perform quadtree decomposition.
%   qtgetblk        - Get block values in quadtree decomposition.
%   qtsetblk        - Set block values in quadtree decomposition.
%
% Image enhancement.
%   adapthisteq    - Perform adaptive histogram equalization using CLAHE.
%   decorrstretch  - Apply a decorrelation stretch to a multichannel image.
%   histeq         - Enhance contrast using histogram equalization.
%   imadjust       - Adjust image intensity values or colormap.
%   imnoise        - Add noise to an image.
%   medfilt2       - Perform 2-D median filtering.
%   ordfilt2       - Perform 2-D order-statistic filtering.
%   stretchlim     - Find limits to contrast stretch an image.
%   uintlut        - Computes new array values based on lookup table.
%   wiener2        - Perform 2-D adaptive noise-removal filtering.
%
% Linear filtering.
%   convmtx2       - Compute 2-D convolution matrix.
%   fspecial       - Create predefined filters.
%   imfilter       - Filter 2-D and N-D images.
%
% Linear 2-D filter design.
%   freqspace      - Determine 2-D frequency response spacing (MATLAB Toolbox).
%   freqz2         - Compute 2-D frequency response.
%   fsamp2         - Design 2-D FIR filter using frequency sampling.
%   ftrans2        - Design 2-D FIR filter using frequency transformation.
%   fwind1         - Design 2-D FIR filter using 1-D window method.
%   fwind2         - Design 2-D FIR filter using 2-D window method.
%
% Image deblurring.
%   deconvblind    - Deblur image using blind deconvolution.
%   deconvlucy     - Deblur image using Lucy-Richardson method.
%   deconvreg      - Deblur image using regularized filter.
%   deconvwnr      - Deblur image using Wiener filter.
%   edgetaper      - Taper edges using point-spread function.
%   otf2psf        - Optical transfer function to point-spread function.
%   psf2otf        - Point-spread function to optical transfer function.
%
% Image transforms.
%   dct2           - 2-D discrete cosine transform.
%   dctmtx         - Discrete cosine transform matrix.
%   fan2para       - Convert fan-beam projections to parallel-beam.
%   fanbeam        - Compute fan-beam transform.
%   fft2           - 2-D fast Fourier transform (MATLAB Toolbox).
%   fftn           - N-D fast Fourier transform (MATLAB Toolbox).
%   fftshift       - Reverse quadrants of output of FFT (MATLAB Toolbox).
%   idct2          - 2-D inverse discrete cosine transform.
%   ifft2          - 2-D inverse fast Fourier transform (MATLAB Toolbox).
%   ifftn          - N-D inverse fast Fourier transform (MATLAB Toolbox).
%   ifanbeam       - Compute inverse fan-beam transform.
%   iradon         - Compute inverse Radon transform.
%   para2fan       - Convert parallel-beam projections to fan-beam.
%   phantom        - Generate a head phantom image.
%   radon          - Compute Radon transform.
%
% Neighborhood and block processing.
%   bestblk        - Choose block size for block processing.
%   blkproc        - Implement distinct block processing for image.
%   col2im         - Rearrange matrix columns into blocks.
%   colfilt        - Columnwise neighborhood operations.
%   im2col         - Rearrange image blocks into columns.
%   nlfilter       - Perform general sliding-neighborhood operations.
%
% Morphological operations (intensity and binary images).
%   conndef        - Default connectivity.
%   imbothat       - Perform bottom-hat filtering.
%   imclearborder  - Suppress light structures connected to image border.
%   imclose        - Close image.
%   imdilate       - Dilate image.
%   imerode        - Erode image.
%   imextendedmax  - Extended-maxima transform.
%   imextendedmin  - Extended-minima transform.
%   imfill         - Fill image regions and holes.
%   imhmax         - H-maxima transform.
%   imhmin         - H-minima transform.
%   imimposemin    - Impose minima.
%   imopen         - Open image.
%   imreconstruct  - Morphological reconstruction.
%   imregionalmax  - Regional maxima.
%   imregionalmin  - Regional minima.
%   imtophat       - Perform tophat filtering.
%   watershed      - Watershed transform.
%
% Morphological operations (binary images).
%   applylut       - Perform neighborhood operations using lookup tables.
%   bwarea         - Compute area of objects in binary image.
%   bwareaopen     - Binary area open (remove small objects).
%   bwdist         - Compute distance transform of binary image.
%   bweuler        - Compute Euler number of binary image.
%   bwhitmiss      - Binary hit-miss operation.
%   bwlabel        - Label connected components in 2-D binary image.
%   bwlabeln       - Label connected components in N-D binary image.
%   bwmorph        - Perform morphological operations on binary image.
%   bwpack         - Pack binary image.
%   bwperim        - Determine perimeter of objects in binary image.
%   bwselect       - Select objects in binary image.
%   bwulterode     - Ultimate erosion.
%   bwunpack       - Unpack binary image.
%   makelut        - Construct lookup table for use with applylut.
%
% Structuring element (STREL) creation and manipulation.
%   getheight      - Get strel height.
%   getneighbors   - Get offset location and height of strel neighbors
%   getnhood       - Get strel neighborhood.
%   getsequence    - Get sequence of decomposed strels.
%   isflat         - Return true for flat strels.
%   reflect        - Reflect strel about its center.
%   strel          - Create morphological structuring element.
%   translate      - Translate strel.
%
% Region-based processing.
%   poly2mask      - Convert region-of-interest polygon to mask.
%   roicolor       - Select region of interest, based on color.
%   roifill        - Smoothly interpolate within arbitrary region.
%   roifilt2       - Filter a region of interest.
%   roipoly        - Select polygonal region of interest.
%
% Colormap manipulation.
%   brighten       - Brighten or darken colormap (MATLAB Toolbox).
%   cmpermute      - Rearrange colors in colormap.
%   cmunique       - Find unique colormap colors and corresponding image.
%   colormap       - Set or get color lookup table (MATLAB Toolbox).
%   imapprox       - Approximate indexed image by one with fewer colors.
%   rgbplot        - Plot RGB colormap components (MATLAB Toolbox).
%
% Color space conversions.
%   applycform     - Apply device-independent color space transformation.
%   hsv2rgb        - Convert HSV values to RGB color space (MATLAB Toolbox).
%   iccread        - Read ICC color profile.
%   lab2double     - Convert Lab color values to double.
%   lab2uint16     - Convert Lab color values to uint16.
%   lab2uint8      - Convert Lab color values to uint8.
%   makecform      - Create device-independent color space transform structure.
%   ntsc2rgb       - Convert NTSC values to RGB color space.
%   rgb2hsv        - Convert RGB values to HSV color space (MATLAB Toolbox).
%   rgb2ntsc       - Convert RGB values to NTSC color space.
%   rgb2ycbcr      - Convert RGB values to YCBCR color space.
%   whitepoint     - Returns XYZ values of standard illuminants.
%   xyz2double     - Convert XYZ color values to double.
%   xyz2uint16     - Convert XYZ color values to uint16.
%   ycbcr2rgb      - Convert YCBCR values to RGB color space.
%
% Interactive mouse utility functions.
%   getline        - Select polyline with mouse.
%   getpts         - Select points with mouse.
%   getrect        - Select rectangle with mouse.
%
% ICC color profiles.
%   lab8.icm       - 8-bit Lab profile.
%   monitor.icm    - Typical monitor profile.
%                    Sequel Imaging, Inc., used with permission.
%   sRGB.icm       - sRGB profile.
%                    Hewlett-Packard, used with permission.
%   swopcmyk.icm   - CMYK input profile.
%                    Eastman Kodak, used with permission.
%
% Array operations.
%   circshift      - Shift array circularly (MATLAB Toolbox).
%   padarray       - Pad array.
%
% Image types and type conversions.
%   dither         - Convert image using dithering.
%   gray2ind       - Convert intensity image to indexed image.
%   grayslice      - Create indexed image from intensity image by thresholding.
%   graythresh     - Compute global image threshold using Otsu's method.
%   im2bw          - Convert image to binary image by thresholding.
%   im2double      - Convert image array to double precision.
%   im2java        - Convert image to Java image (MATLAB Toolbox).
%   im2java2d      - Convert image to Java BufferedImage.
%   im2uint8       - Convert image array to 8-bit unsigned integers.
%   im2uint16      - Convert image array to 16-bit unsigned integers.
%   ind2gray       - Convert indexed image to intensity image.
%   ind2rgb        - Convert indexed image to RGB image (MATLAB Toolbox).
%   label2rgb      - Convert label matrix to RGB image.
%   mat2gray       - Convert matrix to intensity image.
%   rgb2gray       - Convert RGB image or colormap to grayscale.
%   rgb2ind        - Convert RGB image to indexed image.
%
% Toolbox preferences.
%   iptgetpref     - Get value of Image Processing Toolbox preference.
%   iptsetpref     - Set value of Image Processing Toolbox preference.
%
% Demos.
%   iptdemos       - Index of Image Processing Toolbox demos.

% Undocumented functions.
%   cmgamdef       - Default gamma correction table.
%   cmgamma        - Gamma correct colormap.
%   iptgate        - Gateway routine to call private functions.

% Grandfathered functions.
%   bwfill         - Fill background regions in binary image.
%   dctmtx2        - Discrete cosine transform matrix.
%   dilate         - Perform dilation on binary image.
%   erode          - Perform erosion on binary image.
%   imfeature      - Compute feature measurements for image regions.
%   imslice        - Get/put image slices into an image deck.
%   imzoom         - Zoom in and out of image or 2-D plot.
%   im2mis         - Convert image to Java MemoryImageSource.
%   mfilter2       - 2-D region-of-interest filtering.
%   isbw           - Return true for binary image.
%   isgray         - Return true for intensity image.
%   isind          - Return true for indexed image.
%   isrgb          - Return true for RGB image.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision $  $Date: 2003/12/13 02:42:47 $

