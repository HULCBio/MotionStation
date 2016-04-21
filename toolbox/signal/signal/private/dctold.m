function b=dct(a,n)
%DCT  Discrete cosine transform.
%
%   Y = DCT(X) returns the discrete cosine transform of X.
%   The vector Y is the same size as X and contains the
%   discrete cosine transform coefficients.
%
%   Y = DCT(X,N) pads or truncates the vector X to length N 
%   before transforming.
%
%   If X is a matrix, the DCT operation is applied to each
%   column.  This transform can be inverted using IDCT.
%
%   Note:  This function is obsolete and may be removed in
%   future versions in favor of dct.m, which uses a unitary
%   scaling.  If you prefer this function, make a copy of it
%   with a new name.
%
%   See also: DCT, IDCT, IDCTOLD, FFT, and IFFT.

%   Author(s): C. Thompson, 2-12-93
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 01:08:36 $

%   References: 
% Jae S. Lim, "Two-dimensional Signal and Image Processing",
%   pp. 148-162.  Implements an even-symmetrical DCT.
% Jain, "Fundamentals of Digital Image Processing", pp. 150-153.
% Wallace, "The JPEG Still Picture Compression Standard",
%   Communications of the ACM, April 1991.

error(nargchk(1,2,nargin));

if min(size(a))==1 
    if size(a,2)>1
        do_trans = 1;
    else
        do_trans = 0;
    end
    a = a(:); 
else  
    do_trans = 0; 
end
if nargin==1,
  n = size(a,1);
end
m = size(a,2);

% Pad or truncate a if necessary
if size(a,1)<n,
  aa = zeros(n,m);
  aa(1:size(a,1),:) = a;
else
  aa = a(1:n,:);
end

if rem(n,2)==1, % odd case
  % Form intermediate even-symmetric matrix.
  y = zeros(2*n,m);
  y(1:n,:) = aa;
  y(n+1:n+n,:) = flipud(aa);

  % Perform FFT
  yy = fft(y);

  % Compute DCT coefficients
  ww = exp(-i*(0:n-1)*pi/(2*n)).';
  b = ww(:,ones(1,m)).*yy(1:n,:);

else % even case, courtesy of Steven L. Eddins

  % Re-order the elements of the columns of x
  y = [ aa(1:2:n,:); aa(n:-2:2,:) ];

  % Compute weights to multiply DFT coefficients
  ww = 2*exp(-i*(0:n-1)'*pi/(2*n));
  W = ww(:,ones(1,m));

  % Compute DCT using equation (5.92) in Jain
  b = W .* fft(y);
end

if isreal(a), b = real(b); end
if do_trans, b = b.'; end

