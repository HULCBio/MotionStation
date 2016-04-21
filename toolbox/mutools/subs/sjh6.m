% function u = sjh6(a,c)
%
%   Solves the Lyapunov equation  a'*x + x*a + c'*c = 0
%   the solution returned is the Cholesky factor u where
%   u is upper triangular and x = u'*u
%
%   modified by K. Glover  June 1987.
%   it is assumed that a is in upper Schur form on entry.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function u = sjh6(a,c)
%  check if input has any complex inputs
  if any(any(imag(a)))| any(any(imag(c))) realfl=0;
      else realfl=1; end
  [na,ma]=size(a);
  [mc,nc]=size(c);
  n = na; m = mc;
% perform complex Schur form on a
  if realfl [ua,a] = rsf2csf(eye(n),a); end
% qr decomposition of c
  if realfl c=c*ua;end
  c = triu(qr(c));
% now calculate the solution from equations (5.13) - (5.16).
  u = zeros(n);  id=eye(n); y=zeros(1,n-1);
  for i=1:(n-1)
    f = sqrt(-2*real(a(i,i)));
    u(i,i) = abs(c(1,1))/f;
    e = sign(c(1,1))*f;
    if c(1,1)==0
	e=f;
    end
    u(i,(i+1):n) = (-e'*c(1,2:(n-i+1)) -u(i,i)'*a(i,(i+1):n))/...
        (a(i,i)'*id(1:(n-i),1:(n-i)) + a((i+1):n,(i+1):n));
    y(1,1:(n-i)) = c(1,2:(n-i+1)) - e*u(i,(i+1):n);
    if m>1
	c(1:m,1:(n-i)) = triu(qr([c(2:m,2:(n-i+1));y(1,1:(n-i))]));
    else
	c(1:m,1:(n-i)) = y(1:m,1:(n-i));
    end
  end
  f = sqrt(-2*real(a(n,n)));
  u(n,n) = abs(c(1,1))/f;
% now obtain u in upper triangular form
  if ~realfl u = triu(qr(u));, end;
  if realfl u=u*ua'; u(1:n,1:n) = qrsc(u);end;