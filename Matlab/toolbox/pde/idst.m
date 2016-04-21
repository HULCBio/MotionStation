function b=idst(a,n)
%IDST   Inverse discrete sine transform.
%
%       X = IDST(Y) inverts the DST transform, returning the
%       original vector if Y was obtained using Y = DST(X).
%
%       X = IDST(Y,N) pads or truncates the vector Y to length N
%       before transforming.
%
%       If Y is a matrix, the IDST operation is applied to
%       each column.
%
%       See also: FFT, IFFT, DST.

%       A. Nordmark 10-25-94.
%       Copyright 1994-2001 The MathWorks, Inc.
%       $Revision: 1.8 $  $Date: 2001/02/09 17:03:12 $

if nargin==1
  if min(size(a))==1
    n=length(a);
  else
    n=size(a,1);
  end
end

nn=n+1;
b=2/nn*dst(a,n);

