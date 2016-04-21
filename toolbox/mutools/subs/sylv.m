% function X = sylv(A,B,C)
%
%   SYLV(A,B,C) solves the Sylvester equation A*X+X*B=C
%   The method forms the single vector equation using Kronecker
%   products.  This is not generally efficient but is when
%   A or B have low dimension (e.g. 2) and the other is in
%   either Hessenberg or Schur form.
%
%   See Also: AXXBC

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function X = sylv(A,B,C)
[ma,na] = size(A);
[mb,nb] = size(B);

K = zeros(ma*mb,na*nb);
jj = 1-nb:0;

EA = eye(na);

for i = 1:ma
        ik = i:na:(na*mb-na+i);
        K(ik,ik) = B.';
end

for i = 1:mb
        ik = 1+(i-1)*ma:i*ma;
        K(ik,ik) = K(ik,ik) + A;
end

X = zeros(na,mb);
X(:) = K\C(:);