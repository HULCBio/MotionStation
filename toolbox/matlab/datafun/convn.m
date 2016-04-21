function C = convn(A,B,shape)
%CONVN  N-dimensional convolution.
%   C = CONVN(A, B) performs the N-dimensional convolution of
%   matrices A and B.
%   C = CONVN(A, B, 'shape') controls the size of the answer C:
%     'full'   - (default) returns the full N-D convolution
%     'same'   - returns the central part of the convolution that
%                is the same size as A.
%     'valid'  - returns only the part of the result that can be
%                computed without assuming zero-padded arrays.  The
%                size of the result is max(size(A)-size(B)+1,0).
%
%   Class support for inputs A,B:
%      float: double, single
%
%   See also CONV, CONV2.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.3 $  $Date: 2004/03/09 16:16:09 $

error(nargchk(2,3,nargin));

if (nargin < 3)
  shape = 'full';
end

if (issparse(A) || issparse(B))
  error('MATLAB:convn:SparseInput', 'Input arguments must be full.')
end

if ~isfloat(A)
    A = double(A);
end
if ~isfloat(B)
    B = double(B);
end

Aisreal = isreal(A);
Bisreal = isreal(B);

if (Aisreal && Bisreal)
  C = convnc(A,B);
  
elseif (Aisreal && ~Bisreal)
  C = convnc(A,real(B)) + j*convnc(A,imag(B));
  
elseif (~Aisreal && Bisreal)
  C = convnc(real(A),B) + j*convnc(imag(A),B);
  
else
  Ar = real(A);
  Ai = imag(A);
  Br = real(B);
  Bi = imag(B);
  C = convnc(Ar,Br) - convnc(Ai,Bi) + j*(convnc(Ai,Br) + convnc(Ar,Bi));
  
end

if (strcmp(shape,'same'))
  sizeA = [size(A) ones(1,ndims(C)-ndims(A))];
  sizeB = [size(B) ones(1,ndims(C)-ndims(B))];
  flippedKernelCenter = ceil((1 + sizeB)/2);
  subs = cell(1,ndims(C));
  for p = 1:length(subs)
    subs{p} = (1:sizeA(p)) + flippedKernelCenter(p) - 1;
  end
  C = C(subs{:});
  
elseif (strcmp(shape,'valid'))
  sizeB = [size(B) ones(1,ndims(C)-ndims(B))];
  outSize = max([size(A) ones(1,ndims(C)-ndims(A))] - sizeB + 1, 0);
  subs = cell(1,ndims(C));
  for p = 1:length(subs)
    subs{p} = (1:outSize(p)) + sizeB(p) - 1;
  end
  C = C(subs{:});
  
end
