% function t=qrsc(a)
%   given an n x n matrix a, such that a'*a is real,
%   this routine finds an upper triangular matrix t
%   such that a'*a=t'*t.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function t=qrsc(a)
[n,m]=size(a);
temp=qr([real(a);imag(a)]);
t=temp(1:n,1:n);
if n>1,
  for i=2:n,
    for j=1:i-1,
      t(i,j)=0.0;
    end;
  end;
end;

%
%