function psf = otf2psf(varargin)
%OTF2PSF Convert optical transfer function to point-spread function. 
%   PSF = OTF2PSF(OTF) computes the inverse Fast Fourier Transfom (IFFT)
%   of the optical transfer function (OTF) array and creates a point spread
%   function (PSF), centered at the origin. By default, the PSF is the same 
%   size as the OTF.
%
%   PSF = OTF2PSF(OTF,OUTSIZE) converts the OTF array into a PSF array of
%   specified size OUTSIZE. The OUTSIZE must not exceed the size of the
%   OTF array in any dimension.
%
%   To center the PSF at the origin, OTF2PSF circularly shifts the values
%   of the output array down (or to the right) until the (1,1) element
%   reaches the central position, then it crops the result to match
%   dimensions specified by OUTSIZE.
%
%   Note that this function is used in image convolution/deconvolution 
%   when the operations involve the FFT. 
%
%   Class Support
%   -------------
%   OTF can be any nonsparse, numeric array. PSF is of class double. 
%
%   Example
%   -------
%      PSF  = fspecial('gaussian',13,1);
%      OTF  = psf2otf(PSF,[31 31]); % PSF --> OTF
%      PSF2 = otf2psf(OTF,size(PSF)); % OTF --> PSF2
%      subplot(1,2,1); surf(abs(OTF)); title('|OTF|');
%      axis square; axis tight
%      subplot(1,2,2); surf(PSF2); title('corresponding PSF');
%      axis square; axis tight
%       
%   See also PSF2OTF, CIRCSHIFT, PADARRAY.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.12.4.2 $  $Date: 2003/08/01 18:09:33 $

[otf, otfSize, outSize] = ParseInputs(varargin{:});

if ~all(otf(:)==0),
   
   psf = ifftn(otf);

   % Estimate the rough number of operations involved in the 
   % computation of the IFFT 
   nElem = prod(otfSize);
   nOps  = 0;
   for k=1:ndims(otf)
      nffts = nElem/otfSize(k);
      nOps  = nOps + otfSize(k)*log2(otfSize(k))*nffts; 
   end

   % Discard the imaginary part of the psf if it's within roundoff error.
   if max(abs(imag(psf(:))))/max(abs(psf(:))) <= nOps*eps
      psf = real(psf);
   end

   % Circularly shift psf so that (1,1) element is moved to the
   % appropriate center position.
   psf    = circshift(psf,floor(outSize/2));

   % Crop output array.
   idx = cell(1,length(outSize));
   for k = 1:length(outSize)
      idx{k} = 1:outSize(k);
   end
   psf = psf(idx{:});
   
else
   psf = zeros(outSize);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%555
%%% Parse inputs
%%%

function [otf, otfSize, outSize] = ParseInputs(varargin)

error(nargchk(1,2,nargin,'struct'));

switch nargin
case 1       % OTF2PSF(OTF) 
  otf = varargin{1};   
case 2       % OTF2PSF(OTF,OUTSIZE) 
  otf = varargin{1}; 
  outSize = varargin{2};
end;

% Check validity of the input parameters
% otf can be empty. it treats empty array as the fftn does
if ~isnumeric(otf) || issparse(otf),
  eid = sprintf('Images:%s:invalidOTF',mfilename);
  msg = 'Invalid OTF class: must be numeric, non-sparse.';
  error(eid,'%s',msg);
else
  otf = double(otf);
  if ~all(isfinite(otf(:))),
    eid = sprintf('Images:%s:otfContainsInfs',mfilename);
    msg = 'OTF must consist of finite values.';
    error(eid,'%s',msg);
  end
end
otfSize = size(otf);

% outSize:

if nargin==1,
  outSize = otfSize;% by default
elseif ~isa(outSize, 'double')
  eid = sprintf('Images:%s:invalidType',mfilename);
  msg = 'OUTSIZE has to be of class double.';
  error(eid,'%s',msg);
elseif any(outSize<0) | ~isreal(outSize) |...
    all(size(outSize)>1)| ~all(isfinite(outSize)),
  eid = sprintf('Images:%s:invalidOutSize',mfilename);
  msg = 'OUTSIZE has to be a vector of real, positive integers.';
  error(eid,'%s',msg);
end

if isempty(outSize),
  outSize = otfSize;
elseif ~isempty(otf),% empty arrays are treated similar as in the fftn
  [otfSize, outSize] = padlength(otfSize, outSize(:).');
  if any(outSize > otfSize)
    eid = sprintf('Images:%s:outSizeIsGreaterThanOtfSize',mfilename);
    msg1 = 'OUTSIZE must not exceed the size of the OTF array ';
    msg2 = 'in any dimension.';
    error(eid,'%s%s',msg1,msg2);
  end
end
