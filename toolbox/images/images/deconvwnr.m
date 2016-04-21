function J = deconvwnr(varargin)
%DECONVWNR Image restoration using Wiener filter. 
%   J = DECONVWNR(I,PSF) deconvolves image I using Wiener filter
%   algorithm, returning deblurred image J. The assumption is
%   that the image I was created by convolving a true image with a
%   point-spread function PSF and possibly by adding noise. The algorithm
%   is optimal in a sense of least mean square error between the
%   estimated and the true images, and utilizes the correlation matrixes
%   of image and noise. In the absence of noise, the Weiner filter
%   reduces to the ideal inverse filter.
%
%   To improve the restoration, additional parameters can be passed in
%   J = DECONVWNR(I,PSF,NSR)
%   J = DECONVWNR(I,PSF,NCORR,ICORR), where
%
%   NSR is the noise-to-signal power ratio. NSR could be a
%   scalar or an array of the same size as I. Default is 0.
%
%   NCORR and ICORR are the autocorrelation functions of the noise
%   NCORR and the original image ICORR. NCORR and ICORR could be of any
%   size or dimension not exceeding the original image. An N-dimensional
%   NCORR or ICORR array corresponds to the autocorrelation within each
%   dimension. A vector NCORR or ICORR represents an autocorrelation
%   function in first dimension if PSF is a vector. If PSF is an array,
%   the 1-D autocorrelation function is extrapolated by symmetry to all
%   non-singleton dimensions of PSF. A scalar NCORR or ICORR represents
%   the power of the noise or the image.
%
%   Note that the output image J could exhibit ringing introduced by the
%   discrete Fourier transform used in the algorithm. To reduce the
%   ringing use I = EDGETAPER(I,PSF) prior to calling DECONVWNR.
%
%   Class Support
%   -------------
%   I and PSF can be of class uint8, uint16, or double. Other inputs have
%   to be of class double. J is of the same class as I.
%
%   Example
%   -------
%
%      I = checkerboard(8);
%      noise = 0.1*randn(size(I));
%      PSF = fspecial('motion',21,11);
%      Blurred = imfilter(I,PSF,'circular');
%      BlurredNoisy = im2uint8(Blurred + noise);
%      
%      NSR = sum(noise(:).^2)/sum(I(:).^2);% noise-to-power ratio
%      
%      NP = abs(fftn(noise)).^2;% noise power
%      NPOW = sum(NP(:))/prod(size(noise));
%      NCORR = fftshift(real(ifftn(NP)));% noise autocorrelation 
%                                        % function, centered
%      IP = abs(fftn(I)).^2;% original image power
%      IPOW = sum(IP(:))/prod(size(I));
%      ICORR = fftshift(real(ifftn(IP)));% image autocorrelation
%                                        % function, centered
%      ICORR1 = ICORR(:,ceil(size(I,1)/2));
%
%      NSR = NPOW/IPOW;% noise-to-power ratio
%      
%      subplot(221);imshow(BlurredNoisy,[]);
%                     title('A = Blurred and Noisy');
%      subplot(222);imshow(deconvwnr(BlurredNoisy,PSF,NSR),[]);
%                     title('deconvwnr(A,PSF,NSR)');
%      subplot(223);imshow(deconvwnr(BlurredNoisy,PSF,NCORR,ICORR),[]);
%                     title('deconvwnr(A,PSF,NCORR,ICORR)');
%      subplot(224);imshow(deconvwnr(BlurredNoisy,PSF,NPOW,ICORR1),[]);
%                     title('deconvwnr(A,PSF,NPOW,ICORR_1_D)');
%
%   See also DECONVREG, DECONVLUCY, DECONVBLIND, EDGETAPER, PADARRAY, 
%   PSF2OTF, OTF2PSF.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.13.4.1 $

%   References
%   ----------
%   "Digital Image Processing", R. C. Gonzalez & R. E. Woods,
%   Addison-Wesley Publishing Company, Inc., 1992.

% Parse inputs to verify valid function calling syntaxes and arguments
[I, PSF, ncorr, icorr, sizeI, classI, sizePSF, numNSdim] = ...
    parse_inputs(varargin{:});

% First, Optical transfer function has the same size/dims as I
otf = psf2otf(PSF,sizeI);% even if PSF does not

% Second, define the noise to signal power ratio, K. 
% K must have same size/dims as I (unless it is a number)

if isempty(icorr),% noise-to-signal power ratio is given

  K = ncorr;
  nojunk = [1:prod(sizeI)].';% all points are included in the algorithm
  
else % noise & signal frequency characteristics are given
  NSD = length(numNSdim);
  
  acf = {ncorr,icorr};
  for k = 1:2,% analysis is similar for both noise & image ACF
    ACF = acf{k};
    sizeACF = size(ACF);
    if (length(sizeACF)==2)&(sum(sizeACF==1)==1)&(NSD>1),%ACF is 1D
      % autocorrelation function and PSF has more than one non-singleton
      % dimension.Therefore, we extrapolate ACF using symmetry to all PSF
      % non-singleton dimensions & reshavel it to include singletons.
      ACF = CreateNDfrom1D(ACF,NSD,numNSdim,sizePSF);
    end;
    powspec{k} = abs(fftn(ACF,sizeI));% calculate power spectrum
  end;

  % define points that do not trigger warning 1/0
  nojunk = find(abs(powspec{2})>sqrt(eps)*max(abs(powspec{1}(:))));
  K = powspec{1}(nojunk(:))./powspec{2}(nojunk(:));
  
end;

% Third, reconstruct the image
Denom = abs(otf(nojunk(:))).^2 + K;
Nomin = conj(otf).*fftn(I);
clear otf I;

% Make sure that the denominator is not extremely small
whats_tiny = max(abs(Nomin(nojunk(:))))*sqrt(eps);
whers_tiny = find(abs(Denom)<whats_tiny);
signof_tiny = 2*(real(Denom(whers_tiny))>0) - 1;
Denom(whers_tiny) = signof_tiny*whats_tiny;

JFT(prod(sizeI)) = 0;
JFT(nojunk(:)) = Nomin(nojunk(:))./Denom;
clear nojunk Denom Nomin;
J = real(ifftn(reshape(JFT,sizeI)));
clear JFT;

% Convert to the original class 
if ~strcmp(classI,'double'),
  J = changeclass(classI,J);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
function [I, PSF, ncorr, icorr, sizeI, classI, sizePSF, numNSdim] = ...
    parse_inputs(varargin),
% Outputs:  I     the input array (could be any numeric class, 2D, 3D)
%           PSF   operator that applies blurring on the image
%           ncorr is noise power (if scalar), 1D or 2D autocorrelation 
%                 function (acf) of noise, or part of it
%                 it become noise-to-signal power ratio if icorr is empty
%           icorr is signal power (if scalar), 1D or 2D autocorrelation 
%                 function (acf) of signal, or part of it
%           numNSdim non-singleton dimensions of PSF
% Defaults:
ncorr = 0;
icorr = [];

checknargin(2,4,nargin,mfilename);

% First, check validity of class/real/finite for all except image at once:
% J = DECONVWNR(I,PSF,NCORR,ICORR)
input_names={'PSF','NCORR','ICORR'};
for n = 2:nargin,
    checkinput(varargin{n},{'double'},{'real' 'finite'},mfilename,input_names{n-1},n);
end;

% Second, assign the inputs:
I = varargin{1};%        deconvwnr(A,PSF)
PSF = varargin{2};
switch nargin
case 3,%                 deconvwnr(A,PSF,nsr)
  ncorr = varargin{3};
case 4,%                 deconvwnr(A,PSF,ncorr,icorr)
  ncorr = varargin{3};
  icorr = varargin{4};
end

% Third, Check validity of the input parameters: 

% Input image I
sizeI = size(I);
classI = class(I);
checkinput(I,{'uint8' 'uint16' 'double'},{'real' 'finite'},mfilename,'I',1);
if prod(sizeI)<2,
  eid = sprintf('Images:%s:mustHaveAtLeast2Elements',mfilename);
  msg = sprintf('In function %s, input image must have at least two elements.',mfilename);
  error(eid, msg);
elseif ~isa(I,'double')
  I = im2double(I);
end

% PSF array
sizePSF = size(PSF);
if prod(sizePSF)<2,
  eid = sprintf('Images:%s:mustHaveAtLeast2Elements',mfilename);
  msg = sprintf('In function %s, PSF must have at least two elements.',mfilename);
  error(eid,msg);
elseif all(PSF(:)==0),
  eid = sprintf('Images:%s:psfMustNotBeZeroEverywhere',mfilename);
  msg = sprintf('In function %s, PSF cannot be zero everywhere.',mfilename);
  error(eid,msg);
end

% NSR, NCORR, ICORR
if isempty(ncorr)&~isempty(icorr),
  eid = sprintf('Images:%s:invalidInput',mfilename);
  msg = sprintf('Invalid input in function %s: provide characteristics for noise.',mfilename);
  error(eid,msg);
end

% Sizes: PSF size cannot be larger than the image size in non-singleton dims
[sizeI, sizePSF, sizeNCORR] = padlength(sizeI, sizePSF, size(ncorr));
numNSdim = find(sizePSF~=1);
if any(sizeI(numNSdim) < sizePSF(numNSdim))
  eid = sprintf('Images:%s:psfMustBeSmallerThanImage',mfilename);
  msg = sprintf(['In function %s, size of the PSF must not exceed the image' ...
         ' size in any nonsingleton dimension.'], mfilename);
  error(eid,msg);
end

if isempty(icorr)&(prod(sizeNCORR)>1)&~isequal(sizeNCORR,sizeI),
    eid = sprintf('Images:%s:nsrMustBeScalarOrArrayOfSizeA',mfilename);
  error(eid,'DECONVWNR(A,PSF,NSR): NSR has to be a scalar or an array of size A.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function f = CreateNDfrom1D(ACF,NSD,numNSdim,sizePSF)
% create a ND-ACF from 1D-ACF assuming rotational symmetry and preserving
% singleton dimensions as in sizePSF

% First, make a 2D square ACF from the given 1D ACF. Calculate the
% quarter of the 2D square & unfold it symmetrically to the full size. 
% 1. Define grid with a half of the ACF points (assuming that ACF
% is symmetric). Grid is 2D and it values from 0 to 1.
cntr = ceil(length(ACF)/2);%location of the ACF center
vec = [0:(cntr-1)]/(cntr-1);
[x,y] = meshgrid(vec,vec);% grid for the quarter
      
% 2. Calculate radius vector to each grid-point and number the points
% above the diagonal in order to use them later for ACF interpolation.
radvect = sqrt(x.^2+y.^2);
nums = [1;find(triu(radvect)~=0)];

% 3. Interpolate ACF at radius-vector distance for those points.
acf1D = ACF(cntr-1+[1:cntr cntr]);% last point is for the corner.
radvect(nums) = interp1([vec sqrt(2)],acf1D,radvect(nums));

% 4. Unfold 45 degree triangle to a square, and then the square
% quarter to a full square matrix.
radvect = triu(radvect) + triu(radvect,1).';
acf = radvect([cntr:-1:2 1:cntr],[cntr:-1:2 1:cntr]);
        
% Second, once 2D is ready, extrapolate 2D-ACF to NSD-ACF
if NSD > 2,% that is create volumetric ACF
  idx0 = repmat({':'},[1 NSD]);
  nextDimACF = [];
  for n = 3:NSD,% make sure not to exceed the PSF size
    numpoints = min(sizePSF(numNSdim(n)),length(ACF));
    % and take only the central portion of 1D-ACF
    vec = cntr-ceil(numpoints/2)+[1:numpoints];
    for m = 1:numpoints,
      idx = [idx0(1:n-1),{m}];
      nextDimACF(idx{:}) = ACF(vec(m))*acf;
    end;
    acf = nextDimACF;
  end
end;

% Third, reshavel NSD-ACF to the right dimensions to include PSF
% singletons.
idx1 = repmat({1},[1 length(sizePSF)]);
idx1(numNSdim) = repmat({':'},[1 NSD]);
f(idx1{:}) = acf;
      