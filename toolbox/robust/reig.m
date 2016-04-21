function [xr,dd] = reig(a,opt)
%REIG Real ordered eigenvalue/eigenvector.
%
% [XR,DD] = REIG(A,OPT) produces a "real" and "ordered" eigenstructure
%    decomposition such that
%                       -1
%                     XR  * A * XR = DD
%    where
%               XR is a set of "real" eigenvectors that span the
%                  same eigenspace as the complex ones.
%               DD is a real block-diagonal matrix with real eigenvalue
%                  (1x1) and complex eigenvalue (2x2) on the main
%                  diagonal.
%
%    Two options are available:
%
%                    Opt = 1 - - ordered by real parts (default)
%                    Opt = 2 - - ordered by magnitude

% R. Y. Chiang & M. G. Safonov 8/88
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.
% ----------------------------------------------------------------
%

if nargin == 1
   opt = 1;
end

if norm(imag(a),1)~=0, error('IMAG(A)~=0'),end
[n,n] = size(a);
dd = zeros(n,n);
xr = zeros(n,n);
[x,d] = eig(a);
dg = diag(d);
if opt == 1
   [dsort,index] = sort(real(dg));
else
   [dsort,index] = sort(abs(dg));
end
dgs = dg(index);
xs = x(:,index);
j=sqrt(-1);
[junk,ixmax] = max(xs);
i=1;
for k=1:n,
   if abs(imag(dgs(k))) <= 1.e-7*abs(real(dgs(k)))+eps,
      dd(i,i) = real(dgs(k));
      xr(:,i) = real(xs(:,k)*exp(-j*angle(xs(ixmax(k),k))));
      i=i+1;
   else
      if imag(dgs(k)) > 1.e-7*abs(real(dgs(k)))+eps,
         dd(i:i+1,i:i+1) = ...
            [real(dgs(k)) imag(dgs(k));-imag(dgs(k)) real(dgs(k))];
         xr(:,i:i+1) = [real(xs(:,k)) imag(xs(:,k))];
         i=i+2;
      end
   end
end
%
% ------ End of REIG.M % RYC/MGS %