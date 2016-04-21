function a = idct(b,n)
%IDCT Inverse discrete cosine transform.
%
%   X = IDCT(Y) inverts the DCT transform, returning the
%   original vector if Y was obtained using Y = DCT(X).
%
%   X = IDCT(Y,N) pads or truncates the vector Y to length N 
%   before transforming.
%
%   If Y is a matrix, the IDCT operation is applied to
%   each column.
%
%   Note:  This function is obsolete and may be removed in
%   future versions in favor of idct.m, which uses a unitary
%   scaling.  If you prefer this function, make a copy of it
%   with a new name.
%
%   See also: DCT, IDCT, DCTOLD, FFT, IFFT.

%   Author(s): C. Thompson, 2-12-93
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 01:08:39 $

%   References: 
%   1) Jae S. Lim, "Two-dimensional Signal and Image Processing",
%      pp. 148-162.  Implements an even-symmetrical DCT.
%   2) Jain, "Fundamentals of Digital Image Processing", p. 150.
%   3) Wallace, "The JPEG Still Picture Compression Standard",
%      Communications of the ACM, April 1991.

error(nargchk(1,2,nargin));

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

if rem(n,2)==1, % odd case
  % Form intermediate even-symmetric matrix.
  ww = exp(j*(0:n-1)*pi/(2*n)).';
  W = ww(:,ones(1,m));
  yy = zeros(2*n,m);
  yy(1:n,:) = W.*bb;
  yy(n+2:n+n,:) = -j*W(2:n,:).*flipud(bb(2:n,:));

  y = ifft(yy);

  % Extract inverse DCT
  a = y(1:n,:);

else % even case, courtesy of Steven L. Eddins
  % Compute precorrection factor
  ww = exp(j*pi*(0:n-1)/(2*n)).';
  ww(1) = ww(1)/2;
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
