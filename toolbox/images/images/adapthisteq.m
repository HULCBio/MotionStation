function out = adapthisteq(varargin)
%ADAPTHISTEQ Performs Contrast-Limited Adaptive Histogram Equalization (CLAHE).
%   ADAPTHISTEQ enhances the contrast of images by transforming the
%   values in the intensity image I.  Unlike HISTEQ, it operates on small
%   data regions (tiles), rather than the entire image. Each tile's 
%   contrast is enhanced, so that the histogram of the output region
%   approximately matches the specified histogram. The neighboring tiles 
%   are then combined using bilinear interpolation in order to eliminate
%   artificially induced boundaries.  The contrast, especially
%   in homogeneous areas, can be limited in order to avoid amplifying the
%   noise which might be present in the image.
%
%   J = ADAPTHISTEQ(I) Performs CLAHE on the intensity image I.
%
%   J = ADAPTHISTEQ(I,PARAM1,VAL1,PARAM2,VAL2...) sets various parameters.
%   Parameter names can be abbreviated, and case does not matter. Each 
%   string parameter is followed by a value as indicated below:
%
%   'NumTiles'     Two-element vector of positive integers: [M N].
%                  [M N] specifies the number of tile rows and
%                  columns.  Both M and N must be at least 2. 
%                  The total number of image tiles is equal to M*N.
%
%                  Default: [8 8].
%
%   'ClipLimit'    Real scalar from 0 to 1.
%                  'ClipLimit' limits contrast enhancement. Higher numbers 
%                  result in more contrast. 
%       
%                  Default: 0.01.
%
%   'NBins'        Positive integer scalar.
%                  Sets number of bins for the histogram used in building a
%                  contrast enhancing transformation. Higher values result 
%                  in greater dynamic range at the cost of slower processing
%                  speed.
%
%                  Default: 256.
%
%   'Range'        One of the strings: 'original' or 'full'.
%                  Controls the range of the output image data. If 'Range' 
%                  is set to 'original', the range is limited to 
%                  [min(I(:)) max(I(:))]. Otherwise, by default, or when 
%                  'Range' is set to 'full', the full range of the output 
%                  image class is used (e.g. [0 255] for uint8).
%
%                  Default: 'full'.
%
%   'Distribution' Distribution can be one of three strings: 'uniform',
%                  'rayleigh', 'exponential'.
%                  Sets desired histogram shape for the image tiles, by 
%                  specifying a distribution type.
%
%                  Default: 'uniform'.
%
%   'Alpha'        Nonnegative real scalar.
%                  'Alpha' is a distribution parameter, which can be supplied 
%                  when 'Dist' is set to either 'rayleigh' or 'exponential'.
%
%                  Default: 0.4.
%
%   Notes
%   -----
%   - 'NumTiles' specify the number of rectangular contextual regions (tiles)
%     into which the image is divided. The contrast transform function is
%     calculated for each of these regions individually. The optimal number of
%     tiles depends on the type of the input image, and it is best determined
%     through experimentation.
%
%   - The 'ClipLimit' is a contrast factor that prevents over-saturation of the
%     image specifically in homogeneous areas.  These areas are characterized
%     by a high peak in the histogram of the particular image tile due to many
%     pixels falling inside the same gray level range. Without the clip limit,
%     the adaptive histogram equalization technique could produce results that,
%     in some cases, are worse than the original image.
%
%   - ADAPTHISTEQ can use Uniform, Rayleigh, or Exponential distribution as
%     the basis for creating the contrast transform function. The distribution
%     that should be used depends on the type of the input image.
%     For example, underwater imagery appears to look more natural when the
%     Rayleigh distribution is used.
%
%   Class Support
%   -------------
%   Intensity image I can be of class uint8, uint16, or double,
%   and the output image J has the same class as I.
%
%   Example 1
%   ---------
%   Apply Contrast-Limited Adaptive Histogram Equalization to the 
%   rice.png image. Display the enhanced image.
%
%      I = imread('tire.tif');
%      A = adapthisteq(I,'clipLimit',0.02,'Distribution','rayleigh');
%      imview(I);
%      imview(A);
%
%   Example 2
%   ---------
%  
%   Apply Contrast-Limited Adaptive Histogram Equalization to a color 
%   photograph.
%
%      [X MAP] = imread('shadow.tif');
%      RGB = ind2rgb(X,MAP); % convert indexed image to truecolor format
%      cform2lab = makecform('srgb2lab');
%      LAB = applycform(RGB, cform2lab); %convert image to L*a*b color space
%      L = LAB(:,:,1)/100; % scale the values to range from 0 to 1
%      LAB(:,:,1) = adapthisteq(L,'NumTiles',[8 8],'ClipLimit',0.005)*100;
%      cform2srgb = makecform('lab2srgb');
%      J = applycform(LAB, cform2srgb); %convert back to RGB
%      imview(RGB); %display the results
%      imview(J);
%
%   See also HISTEQ.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/05/03 17:50:00 $

%   References:
%      Karel Zuiderveld, "Contrast Limited Adaptive Histogram Equalization",
%      Graphics Gems IV, p. 474-485, code: p. 479-484
%
%      Hanumant Singh, Woods Hole Oceanographic Institution, personal
%      communication

%--------------------------- The algorithm ----------------------------------
%
%  1. Obtain all the inputs: 
%    * image
%    * number of regions in row and column directions
%    * number of bins for the histograms used in building image transform
%      function (dynamic range)
%    * clip limit for contrast limiting (normalized from 0 to 1)
%    * other miscellaneous options
%  2. Pre-process the inputs:  
%    * determine real clip limit from the normalized value
%    * if necessary, pad the image before splitting it into regions
%  3. Process each contextual region (tile) thus producing gray level mappings
%    * extract a single image region
%    * make a histogram for this region using the specified number of bins
%    * clip the histogram using clip limit
%    * create a mapping (transformation function) for this region
%  4. Interpolate gray level mappings in order to assemble final CLAHE image
%    * extract cluster of four neighboring mapping functions
%    * process image region partly overlapping each of the mapping tiles
%    * extract a single pixel, apply four mappings to that pixel, and 
%      interpolate between the results to obtain the output pixel; repeat
%      over the entire image
%
%  See M-code for further details.
%
%-----------------------------------------------------------------------------

[I, selectedRange, fullRange, numTiles, dimTile, clipLimit, numBins, ...
 noPadRect, distribution, alpha] = parseInputs(varargin{:});

tileMappings = makeTileMappings(I, numTiles, dimTile, numBins, clipLimit, ...
                                selectedRange, fullRange, distribution, alpha);

%Synthesize the output image based on the individual tile mappings. 
out = makeClaheImage(I, tileMappings, numTiles, selectedRange, numBins,...
                     dimTile);

if ~isempty(noPadRect) %do we need to remove padding?
  out = out(noPadRect.ulRow:noPadRect.lrRow, ...
            noPadRect.ulCol:noPadRect.lrCol);
end

%-----------------------------------------------------------------------------

function tileMappings = ...
    makeTileMappings(I, numTiles, dimTile, numBins, clipLimit,...
                     selectedRange, fullRange, distribution, alpha)

numPixInTile = prod(dimTile);

% extract and process each tile
imgCol = 1;
for col=1:numTiles(2),
  imgRow = 1;
  for row=1:numTiles(1),
    
    tile = I(imgRow:imgRow+dimTile(1)-1,imgCol:imgCol+dimTile(2)-1);

    % for speed, call MEX file directly thus avoiding costly
    % input parsing of imhist
    tileHist = imhistc(tile, numBins, 1, fullRange(2)); 
    
    tileHist = clipHistogram(tileHist, clipLimit, numBins);
    
    tileMapping = makeMapping(tileHist, selectedRange, fullRange, ...
                              numPixInTile, numBins, distribution, alpha);
    
    % assemble individual tile mappings by storing them in a cell array;
    tileMappings{row,col} = tileMapping;

    imgRow = imgRow + dimTile(1);    
  end
  imgCol = imgCol + dimTile(2); % move to the next column of tiles
end

%-----------------------------------------------------------------------------
% Calculate the equalized lookup table (mapping) based on cumulating the input 
% histogram.  Note: lookup table is rescaled in the selectedRange [Min..Max].

function mapping = makeMapping(imgHist, selectedRange, fullRange, ...
                               numPixInTile, numBins, distribution, alpha)

mapping = zeros(size(imgHist));
histSum = cumsum(imgHist);
valSpread  = selectedRange(2) - selectedRange(1);

switch distribution
 case 'uniform',
  scale =  valSpread/numPixInTile;
  mapping = min(selectedRange(1) + histSum*scale,...
                selectedRange(2)); %limit to max
  
 case 'rayleigh', % suitable for underwater imagery
  % pdf = (t./alpha^2).*exp(-t.^2/(2*alpha^2))*U(t)
  % cdf = 1-exp(-t.^2./(2*alpha^2))
  hconst = 2*alpha^2;
  vmax = 1 - exp(-1/hconst);
  val = vmax*(histSum/numPixInTile);
  val(val>=1) = 1-eps; % avoid log(0)
  temp = sqrt(-hconst*log(1-val));
  mapping = min(selectedRange(1)+temp*valSpread,...
                selectedRange(2)); %limit to max
  
 case 'exponential',
  % pdf = alpha*exp(-alpha*t)*U(t)
  % cdf = 1-exp(-alpha*t)
  vmax = 1 - exp(-alpha);
  val = (vmax*histSum/numPixInTile);
  val(val>=1) = 1-eps;
  temp = -1/alpha*log(1-val);
  mapping = min(selectedRange(1)+temp*valSpread,selectedRange(2));
  
 otherwise,
  eid = sprintf('Images:%s:internalError', mfilename);
  msg   = 'Unknown distribution type.'; %should never get here
  error(eid, msg);
  
end

%rescale the result to be between 0 and 1 for later use by the GRAYXFORM 
%private mex function
mapping = mapping/fullRange(2);

%-----------------------------------------------------------------------------
% This function clips the histogram according to the clipLimit and
% redistributes clipped pixels accross bins below the clipLimit

function imgHist = clipHistogram(imgHist, clipLimit, numBins)

% total number of pixels overflowing clip limit in each bin
totalExcess = sum(max(imgHist - clipLimit,0));  

% clip the histogram and redistribute the excess pixels in each bin
avgBinIncr = floor(totalExcess/numBins);
upperLimit = clipLimit - avgBinIncr; % bins larger than this will be
                                     % set to clipLimit

% this loop should speed up the operation by putting multiple pixels
% into the "obvious" places first
for k=1:numBins
  if imgHist(k) > clipLimit
    imgHist(k) = clipLimit;
  else
    if imgHist(k) > upperLimit % high bin count
      totalExcess = totalExcess - (clipLimit - imgHist(k));
      imgHist(k) = clipLimit;
    else
      totalExcess = totalExcess - avgBinIncr;
      imgHist(k) = imgHist(k) + avgBinIncr;      
    end
  end
end

% this loops redistributes the remaining pixels, one pixel at a time
k = 1;
while (totalExcess ~= 0)
  %keep increasing the step as fewer and fewer pixels remain for
  %the redistribution (spread them evenly)
  stepSize = max(floor(numBins/totalExcess),1);
  for m=k:stepSize:numBins
    if imgHist(m) < clipLimit
      imgHist(m) = imgHist(m)+1;
      totalExcess = totalExcess - 1; %reduce excess
      if totalExcess == 0
        break;
      end
    end
  end
  
  k = k+1; %prevent from always placing the pixels in bin #1
  if k > numBins % start over if numBins was reached
    k = 1;
  end
end

%-----------------------------------------------------------------------------
% This function interpolates between neighboring tile mappings to produce a 
% new mapping in order to remove artificially induced tile borders.  
% Otherwise, these borders would become quite visible.  The resulting
% mapping is applied to the input image thus producing a CLAHE processed
% image.

function claheI = makeClaheImage(I, tileMappings, numTiles, selectedRange,...
                                 numBins, dimTile)

%initialize the output image to zeros (preserve the class of the input image)
claheI = I;
claheI(:) = 0;

%compute the LUT for looking up original image values in the tile mappings,
%which we created earlier
if ~isa(I,'double')
  k = selectedRange(1)+1 : selectedRange(2)+1;
  aLut(k) = (k-1)-selectedRange(1);
  aLut = aLut/(selectedRange(2)-selectedRange(1));
else
  % remap from 0..1 to 0..numBins-1
  if numBins ~= 1
    binStep = 1/(numBins-1);
    start = ceil(selectedRange(1)/binStep);
    stop  = floor(selectedRange(2)/binStep);
    k = start+1:stop+1;
    aLut(k) = 0:1/(length(k)-1):1;
  else
    aLut(1) = 0; %in case someone specifies numBins = 1, which is just silly
  end
end

imgTileRow=1;
for k=1:numTiles(1)+1
  if k == 1  %special case: top row
    imgTileNumRows = dimTile(1)/2; %always divisible by 2 because of padding
    mapTileRows = [1 1];
  else 
    if k == numTiles(1)+1 %special case: bottom row      
      imgTileNumRows = dimTile(1)/2;
      mapTileRows = [numTiles(1) numTiles(1)];
    else %default values
      imgTileNumRows = dimTile(1); 
      mapTileRows = [k-1, k]; %[upperRow lowerRow]
    end
  end
  
  % loop over columns of the tileMappings cell array
  imgTileCol=1;
  for l=1:numTiles(2)+1
    if l == 1 %special case: left column
      imgTileNumCols = dimTile(2)/2;
      mapTileCols = [1, 1];
    else
      if l == numTiles(2)+1 % special case: right column
        imgTileNumCols = dimTile(2)/2;
        mapTileCols = [numTiles(2), numTiles(2)];
      else %default values
        imgTileNumCols = dimTile(2);
        mapTileCols = [l-1, l]; % right left
      end
    end
    
    % Extract four tile mappings
    ulMapTile = tileMappings{mapTileRows(1), mapTileCols(1)};
    urMapTile = tileMappings{mapTileRows(1), mapTileCols(2)};
    blMapTile = tileMappings{mapTileRows(2), mapTileCols(1)};
    brMapTile = tileMappings{mapTileRows(2), mapTileCols(2)};

    % Calculate the new greylevel assignments of pixels 
    % within a submatrix of the image specified by imgTileIdx. This 
    % is done by a bilinear interpolation between four different mappings 
    % in order to eliminate boundary artifacts.
    
    normFactor = imgTileNumRows*imgTileNumCols; %normalization factor  
    imgTileIdx = {imgTileRow:imgTileRow+imgTileNumRows-1, ...
                 imgTileCol:imgTileCol+imgTileNumCols-1};

    imgPixVals = grayxform(I(imgTileIdx{1},imgTileIdx{2}), aLut);
    
    % calculate the weights used for linear interpolation between the
    % four mappings
    rowW = repmat((0:imgTileNumRows-1)',1,imgTileNumCols);
    colW = repmat(0:imgTileNumCols-1,imgTileNumRows,1);
    rowRevW = repmat((imgTileNumRows:-1:1)',1,imgTileNumCols);
    colRevW = repmat(imgTileNumCols:-1:1,imgTileNumRows,1);
    
    claheI(imgTileIdx{1}, imgTileIdx{2}) = ...
        (rowRevW .* (colRevW .* double(grayxform(imgPixVals,ulMapTile)) + ...
                     colW    .* double(grayxform(imgPixVals,urMapTile)))+ ...
         rowW    .* (colRevW .* double(grayxform(imgPixVals,blMapTile)) + ...
                     colW    .* double(grayxform(imgPixVals,brMapTile))))...
        /normFactor;
    
    imgTileCol = imgTileCol + imgTileNumCols;    
  end %over tile cols
  imgTileRow = imgTileRow + imgTileNumRows;
end %over tile rows

%-----------------------------------------------------------------------------

function [I, selectedRange, fullRange, numTiles, dimTile, clipLimit,...
          numBins, noPadRect, distribution, alpha] = parseInputs(varargin)

checknargin(1,13,nargin,mfilename);

I = varargin{1};
checkinput(I, {'uint8' 'uint16' 'double'}, ...
           {'real', '2d', 'nonsparse', 'nonempty'}, ...
           mfilename, 'I', 1);

if any(size(I) < 2)
  eid = sprintf('Images:%s:inputImageTooSmall', mfilename);
  msg = 'The input image width and height must be at least equal to 2.';
  error(eid, msg);
end

%Other options
%%%%%%%%%%%%%%

%Set the defaults
distribution = 'uniform';
alpha   = 0.4;

if isa(I, 'double')
  fullRange = [0 1];
else
  fullRange(1) = I(1);         %copy class of the input image
  fullRange(1:2) = [-Inf Inf]; %will be clipped to min and max
  fullRange = double(fullRange);
end

selectedRange   = fullRange;

%Set the default to 256 bins regardless of the data type;
%the user can override this value at any time
numBins = 256;
normClipLimit = 0.01;
numTiles = [8 8];

checkAlpha = false;

validStrings = {'NumTiles','ClipLimit','NBins','Distribution',...
                'Alpha','Range'};

if nargin > 1
  done = false;

  idx = 2;
  while ~done
    input = varargin{idx};
    inputStr = checkstrs(input, validStrings,mfilename,'PARAM',idx);

    idx = idx+1; %advance index to point to the VAL portion of the input 

    if idx > nargin
      eid = sprintf('Images:%s:valFor%sMissing', mfilename, inputStr);
      msg = sprintf('Parameter ''%s'' must be followed by a value.', inputStr);
      error(eid, msg);        
    end
    
    switch inputStr

     case 'NumTiles'
       numTiles = varargin{idx};
       checkinput(numTiles, {'double'}, {'real', 'vector', ...
                           'integer', 'finite','positive'},...
                  mfilename, inputStr, idx);

       if (any(size(numTiles) ~= [1,2]))
         eid = sprintf('Images:%s:invalidNumTiles', mfilename);
         msg = sprintf(['Value of parameter,''%s'', must be a two '...
                        'element row vector.'], inputStr);
         error(eid, msg);
       end
       
       if any(numTiles < 2)
         eid = sprintf('Images:%s:invalidNumTiles', mfilename);
         msg = sprintf(['Both elements of ''%s'' value ',... 
                        'must be greater or equal to 2.'],...
                        inputStr);
         error(eid, msg);
       end
      
     case 'ClipLimit'
      normClipLimit = varargin{idx};
      checkinput(normClipLimit, {'double'}, ...
                 {'scalar','real','nonnegative'},...
                 mfilename, inputStr, idx);
      
      if normClipLimit > 1
        eid = sprintf('Images:%s:invalidClipLimit', mfilename);
        msg = sprintf(['Value of parameter ''%s'' must be in the range ',...
                       'from 0 to 1.'], inputStr);
        error(eid, msg);
      end
     
     case 'NBins'
      numBins = varargin{idx};      
      checkinput(numBins, {'double'}, {'scalar','real','integer',...
                          'positive'}, mfilename, 'NBins', idx);
     
     case 'Distribution'
      validDist = {'rayleigh','exponential','uniform'};
      distribution = checkstrs(varargin{idx}, validDist, mfilename,...
                          'Distribution', idx);
     
     case 'Alpha'
      alpha = varargin{idx};
      checkinput(alpha, {'double'},{'scalar','real',...
                          'nonnan','positive','finite'},...
                 mfilename, 'Alpha',idx);
      checkAlpha = true;

     case 'Range'
      validRangeStrings = {'original','full'};
      rangeStr = checkstrs(varargin{idx}, validRangeStrings,mfilename,...
                           'Range',idx);
      
      if strmatch(rangeStr,'original')
        selectedRange = double([min(I(:)), max(I(:))]);;
      end
     
     otherwise
      eid = sprintf('Images:%s:internalError', mfilename);
      msg   = 'Unknown input string.'; %should never get here
      error(eid, msg);
    end
    
    if idx >= nargin
      done = true;
      break;
    end
    
    idx=idx+1;
  end
end


%% Pre-process the inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%

dimI = size(I);
dimTile = dimI ./ numTiles;

%check if tile size is reasonable
if any(dimTile < 1)
  eid = sprintf('Images:%s:inputImageTooSmall', mfilename);
  msg = sprintf(['The image I is too small to be split into [%s] ',...
                 'number of tiles.'], num2str(numTiles));
  error(eid, msg);
end

if checkAlpha
  if strcmp(distribution,'uniform')
    eid = sprintf('Images:%s:alphaShouldNotBeSpecified', mfilename);
    msg = sprintf(['Parameter ''Alpha'' cannot be specified for',...
                   ' ''%s'' distribution.'], distribution);
    error(eid, msg);
  end
end

%check if the image needs to be padded; pad if necessary;
%padding occurs if any dimension of a single tile is an odd number
%and/or when image dimensions are not divisible by the selected 
%number of tiles
rowDiv  = mod(dimI(1),numTiles(1)) == 0;
colDiv  = mod(dimI(2),numTiles(2)) == 0;

if rowDiv && colDiv
  rowEven = mod(dimTile(1),2) == 0;
  colEven = mod(dimTile(2),2) == 0;  
end

noPadRect = [];
if  ~(rowDiv && colDiv && rowEven && colEven)
  padRow = 0;
  padCol = 0;
  
  if ~rowDiv
    rowTileDim = floor(dimI(1)/numTiles(1)) + 1;
    padRow = rowTileDim*numTiles(1) - dimI(1);
  else
    rowTileDim = dimI(1)/numTiles(1);
  end
  
  if ~colDiv
    colTileDim = floor(dimI(2)/numTiles(2)) + 1;
    padCol = colTileDim*numTiles(2) - dimI(2);
  else
    colTileDim = dimI(2)/numTiles(2);
  end
  
  %check if tile dimensions are even numbers
  rowEven = mod(rowTileDim,2) == 0;
  colEven = mod(colTileDim,2) == 0;
  
  if ~rowEven
    padRow = padRow+numTiles(1);
  end

  if ~colEven
    padCol = padCol+numTiles(2);
  end
  
  padRowPre  = floor(padRow/2);
  padRowPost = ceil(padRow/2);
  padColPre  = floor(padCol/2);
  padColPost = ceil(padCol/2);
  
  I = padarray(I,[padRowPre  padColPre ],'symmetric','pre');
  I = padarray(I,[padRowPost padColPost],'symmetric','post');

  %UL corner (Row, Col), LR corner (Row, Col)
  noPadRect.ulRow = padRowPre+1;
  noPadRect.ulCol = padColPre+1;
  noPadRect.lrRow = padRowPre+dimI(1);
  noPadRect.lrCol = padColPre+dimI(2);
end

%redefine this variable to include the padding
dimI = size(I);

%size of the single tile
dimTile = dimI ./ numTiles;

%compute actual clip limit from the normalized value entered by the user
%maximum value of normClipLimit=1 results in standard AHE, i.e. no clipping;
%the minimum value minClipLimit would uniformly distribute the image pixels
%across the entire histogram, which would result in the lowest possible
%contrast value
numPixInTile = prod(dimTile);
minClipLimit = ceil(numPixInTile/numBins);
clipLimit = minClipLimit + round(normClipLimit*(numPixInTile-minClipLimit));

%-----------------------------------------------------------------------------
