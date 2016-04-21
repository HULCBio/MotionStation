function a = idct(b,n)
%IDCT Inverse discrete cosine transform.
%
%   X = IDCT(Y) inverts the DCT transform, returning the original
%   vector if Y was obtained using Y = DCT(X). 
%
%   X = IDCT(Y,N) pads or truncates the vector Y to length N
%   before transforming. 
%
%   If Y is a matrix, the IDCT operation is applied to each
%   column.
%
%   See also FFT,IFFT,DCT.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.12.4.1 $  $Date: 2003/01/26 05:59:37 $

%   References: 
%       1) A. K. Jain, "Fundamentals of Digital Image
%          Processing", pp. 150-153.
%       2) Wallace, "The JPEG Still Picture Compression Standard",
%          Communications of the ACM, April 1991.

checknargin(1,2,nargin,mfilename);

if ~isa(b, 'double')
   b = double(b);
end

if min(size(b))==1 
    if size(b,2)>1
        do_trans = 1;
    else
        do_trans = 0;
    end
    b = b(:); 
else  
    do_trans = 0; 
end
if nargin==1,
  n = size(b,1);
end
m = size(b,2);

% Pad or truncate b if necessary
if size(b,1)<n,
  bb = zeros(n,m);
  bb(1:size(b,1),:) = b;
else
  bb = b(1:n,:);
end

if rem(n,2)==1 | ~isreal(b), % odd case
  % Form intermediate even-symmetric matrix.
  ww = sqrt(2*n) * exp(j*(0:n-1)*pi/(2*n)).';
  ww(1) = ww(1) * sqrt(2);
  W = ww(:,ones(1,m));
  yy = zeros(2*n,m);
  yy(1:n,:) = W.*bb;
  yy(n+2:n+n,:) = -j*W(2:n,:).*flipud(bb(2:n,:));

  y = ifft(yy);

  % Extract inverse DCT
  a = y(1:n,:);

else % even case
  % Compute precorrection factor
  ww = sqrt(2*n) * exp(j*pi*(0:n-1)/(2*n)).';
  ww(1) = ww(1)/sqrt(2);
  W = ww(:,ones(1,m));

  % Compute x tilde using equation (5.93) in Jain
  y = ifft(W.*bb);

  % Re-order elements of each column according to equations (5.93) and
  % (5.94) in Jain
  a = zeros(n,m);
  a(1:2:n,:) = y(1:n/2,:);
  a(2:2:n,:) = y(n:-1:n/2+1,:);
end

if isreal(b), a = real(a); end
if do_trans, a = a.'; end
