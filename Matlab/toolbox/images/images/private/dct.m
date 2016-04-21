function b=dct(a,n)
%DCT Discrete cosine transform.
%
%   Y = DCT(X) returns the discrete cosine transform of X. The
%   vector Y is the same size as X and contains the discrete
%   cosine transform coefficients.  
%
%   Y = DCT(X,N) pads or truncates the vector X to length N
%   before transforming.  
%
%   If X is a matrix, the DCT operation is applied to each
%   column.  This transform can be inverted using IDCT.  
%
%   See also FFT,IFFT, and IDCT.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.12.4.2 $  $Date: 2003/08/23 05:53:40 $

%   References: 
%       1) A. K. Jain, "Fundamentals of Digital Image
%          Processing", pp. 150-153.
%       2) Wallace, "The JPEG Still Picture Compression Standard",
%          Communications of the ACM, April 1991.

checknargin(1,2,nargin,mfilename);

if ~isa(a, 'double')
   a = double(a);
end

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

if ((rem(n,2)==1) || (~isreal(a))) % odd case
  % Form intermediate even-symmetric matrix.
  y = zeros(2*n,m);
  y(1:n,:) = aa;
  y(n+1:n+n,:) = flipud(aa);

  % Perform FFT
  yy = fft(y);

  % Compute DCT coefficients
  ww = (exp(-i*(0:n-1)*pi/(2*n))/sqrt(2*n)).';
  ww(1) = ww(1) / sqrt(2);
  b = ww(:,ones(1,m)).*yy(1:n,:);

else % even case

  % Re-order the elements of the columns of x
  y = [ aa(1:2:n,:); aa(n:-2:2,:) ];

  % Compute weights to multiply DFT coefficients
  ww = 2*exp(-i*(0:n-1)'*pi/(2*n))/sqrt(2*n);
  ww(1) = ww(1) / sqrt(2);
  W = ww(:,ones(1,m));

  % Compute DCT using equation (5.92) in Jain
  b = W .* fft(y);
end

if isreal(a), b = real(b); end
if do_trans, b = b.'; end

