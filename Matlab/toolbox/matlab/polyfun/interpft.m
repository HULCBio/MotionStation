function y = interpft(x,ny,dim)
%INTERPFT 1-D interpolation using FFT method.
%   Y = INTERPFT(X,N) returns a vector Y of length N obtained
%   by interpolation in the Fourier transform of X. 
%
%   If X is a matrix, interpolation is done on each column.
%   If X is an array, interpolation is performed along the first
%   non-singleton dimension.
%
%   INTERPFT(X,N,DIM) performs the interpolation along the
%   dimension DIM.
%
%   Assume x(t) is a periodic function of t with period p, sampled
%   at equally spaced points, X(i) = x(T(i)) where T(i) = (i-1)*p/M,
%   i = 1:M, M = length(X).  Then y(t) is another periodic function
%   with the same period and Y(j) = y(T(j)) where T(j) = (j-1)*p/N,
%   j = 1:N, N = length(Y).  If N is an integer multiple of M,
%   then Y(1:N/M:N) = X.
%
%   Class support for data input x:
%      float: double, single
%  
%   See also INTERP1.

%   Robert Piche, Tampere University of Technology, 10/93.
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.15.4.2 $  $Date: 2004/03/02 21:47:48 $

error(nargchk(2,3,nargin));

if nargin==2,
  [x,nshifts] = shiftdim(x);
  if numel(x)==1, nshifts = 1; end % Return a row for a scalar
elseif nargin==3,
  perm = [dim:max(length(size(x)),dim) 1:dim-1];
  x = permute(x,perm);
end

siz = size(x);
[m,n] = size(x);
if numel(ny)~=1 
  error('MATLAB:interpft:NonScalarN', 'N must be a scalar.'); 
end

%  If necessary, increase ny by an integer multiple to make ny > m.
if ny > m
   incr = 1;
else
   if ny==0, y=[]; return, end
   incr = floor(m/ny) + 1;
   ny = incr*ny;
end
a = fft(x,[],1);
nyqst = ceil((m+1)/2);
b = [a(1:nyqst,:) ; zeros(ny-m,n) ; a(nyqst+1:m,:)];
if rem(m,2) == 0
   b(nyqst,:) = b(nyqst,:)/2;
   b(nyqst+ny-m,:) = b(nyqst,:);
end
y = ifft(b,[],1);
if isreal(x), y = real(y); end
y = y * ny / m;
y = y(1:incr:ny,:);  % Skip over extra points when oldny <= m.

if nargin==2,
  y = reshape(y,[ones(1,nshifts) size(y,1) siz(2:end)]);
elseif nargin==3,
  y = ipermute(y,perm);
end
