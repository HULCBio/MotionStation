function otf = psf2otf(varargin)
%PSF2OTF Convert point-spread function to optical transfer function.
%   OTF = PSF2OTF(PSF) computes the Fast Fourier Transform (FFT) of the
%   point-spread function (PSF) array and creates the optical transfer
%   function (OTF) array that is not influenced by the PSF off-centering. By
%   default, the OTF array is the same size as the PSF array.
% 
%   OTF = PSF2OTF(PSF,OUTSIZE) converts the PSF array into an OTF array of
%   specified size OUTSIZE. The OUTSIZE cannot be smaller than the the PSF
%   array size in any dimension.
%
%   To ensure that the OTF is not altered due to PSF off-centering, PSF2OTF
%   post-pads the PSF array (down or to the right) with zeros to match
%   dimensions specified in OUTSIZE, then circularly shifts the values of
%   the PSF array up (or to the left) until the central pixel reaches (1,1)
%   position.
%
%   Note that this function is used in image convolution/deconvolution 
%   when the operations involve the FFT. 
%
%   Class Support
%   -------------
%   PSF can be any nonsparse, numeric array. OTF is of class double. 
%
%   Example
%   -------
%      PSF  = fspecial('gaussian',13,1);
%      OTF  = psf2otf(PSF,[31 31]); % PSF --> OTF
%      subplot(1,2,1); surf(PSF); title('PSF');
%      axis square; axis tight
%      subplot(1,2,2); surf(abs(OTF)); title('corresponding |OTF|');
%      axis square; axis tight
%
%   See also OTF2PSF, CIRCSHIFT, PADARRAY.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.13.4.2 $  $Date: 2003/08/01 18:11:30 $

[psf, psfSize, outSize] = ParseInputs(varargin{:});

if  ~all(psf(:)==0),
   
   % Pad the PSF to outSize
   padSize = outSize - psfSize;
   psf     = padarray(psf, padSize, 'post');

   % Circularly shift otf so that the "center" of the PSF is at the
   % (1,1) element of the array.
   psf    = circshift(psf,-floor(psfSize/2));

   % Compute the OTF
   otf = fftn(psf);

   % Estimate the rough number of operations involved in the 
   % computation of the FFT.
   nElem = prod(psfSize);
   nOps  = 0;
   for k=1:ndims(psf)
      nffts = nElem/psfSize(k);
      nOps  = nOps + psfSize(k)*log2(psfSize(k))*nffts; 
   end

   % Discard the imaginary part of the psf if it's within roundoff error.
   if max(abs(imag(otf(:))))/max(abs(otf(:))) <= nOps*eps
      otf = real(otf);
   end
else
   otf = zeros(outSize);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Parse inputs
%%%

function [psf, psfSize, outSize] = ParseInputs(varargin)

error(nargchk(1,2,nargin,'struct'));
switch nargin
case 1       % PSF2OTF(PSF) 
  psf = varargin{1};   
case 2       % PSF2OTF(PSF,OUTSIZE) 
  psf = varargin{1}; 
  outSize = varargin{2};
end;

% Check validity of the input parameters
% psf can be empty. it treats empty array as the fftn does
if ~isnumeric(psf) || issparse(psf)
  eid = sprintf('Images:%s:expectedNonSparseAndNumeric',mfilename);
  msg = 'Invalid PSF class: must be numeric, non-sparse.';
  error(eid,'%s',msg);
else
  psf = double(psf);
  if ~all(isfinite(psf(:)))
    eid = sprintf('Images:%s:expectedFinite',mfilename);
    msg = 'PSF must consist of finite values.';
    error(eid,'%s',msg);
  end
end
psfSize = size(psf);

% outSize:
if nargin==1,
  outSize = psfSize;% by default
elseif ~isa(outSize, 'double')
  eid = sprintf('Images:%s:invalidType',mfilename);
  msg = 'OUTSIZE has to be of class double.';
  error(eid,'%s',msg);
elseif any(outSize<0) | ~isreal(outSize) |...
    all(size(outSize)>1) | ~all(isfinite(outSize))
  eid = sprintf('Images:%s:invalidOutSize',mfilename);
  msg = 'OUTSIZE has to be a vector of real, positive integers.';
  error(eid,'%s',msg);
end

if isempty(outSize),
  outSize = psfSize;
elseif ~isempty(psf),% empty arrays are treated similar as in the fftn
  [psfSize, outSize] = padlength(psfSize, outSize(:).');
  if any(outSize < psfSize)
    eid = sprintf('Images:%s:outSizeIsSmallerThanPsfSize',mfilename);
    msg1 = 'OUTSIZE cannot be smaller than the PSF array size in any ';
    msg2 = 'dimension.';
    error(eid,'%s%s',msg1,msg2);
  end
end
