function Q = fipert_qr(A,B,C);
%FIPERT_QR  private function

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:21:46 $

[n,m]  = size(B);
In = eye(n);

X = [ kron(A.',In) - kron(In,A) ; kron(B.',In) ;- kron(In,C)];
[m,z] = size(X);

[QQ,R] = qr(X);
Q = QQ(:,n*n+1:m);

