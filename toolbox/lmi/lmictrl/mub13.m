% Called by MUSTAB: not meant to be called directly
%
% Solves the one- and three-point problems in the mu
% upper bound computation

% Author: P. Gahinet  2/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [alpha,D,G,xinit]=...
           mub13(lmi0,target,isG,tinit,xinit,x0,a,b,c,d,e,w1,w2)


fprintf(1,'.');
j=sqrt(-1); n=size(d,1); G=0;


if w1<Inf, M=d+c*((j*w1*e-a)\b); else M=d; end
M1=real(M); M2=imag(M);
E=[M1 M2;-M2 M1]; F=[-M2 M1;-M1 -M2];
normM=norm(M,'fro');

setlmis(lmi0);
lmiterm([2 1 1 1],E',E);
if isG, lmiterm([2 1 1 2],1,F,'s'); end

if nargin>12,

  if w2<Inf, wc=(w1+w2)/2; else wc=10*w1; end
  M=d+c*((j*wc*e-a)\b); normM=max(normM,norm(M,'fro'));
  M1=real(M); M2=imag(M);
  E=[M1 M2;-M2 M1]; F=[-M2 M1;-M1 -M2];
  lmiterm([3 1 1 1],E',E);
  lmiterm([3 1 1 2],1,F,'s');
  lmiterm([-3 1 1 1],1,1);

  if w2<Inf, M=d+c*((j*w2*e-a)\b); else M=d; end
  M1=real(M); M2=imag(M); normM=max(normM,norm(M,'fro'));
  E=[M1 M2;-M2 M1]; F=[-M2 M1;-M1 -M2];
  lmiterm([4 1 1 1],E',E);
  lmiterm([4 1 1 2],1,F,'s');
  lmiterm([-4 1 1 1],1,1);

end

lmis=getlmis;

% initial point
normM=normM^2;
if ~tinit | tinit > 2*normM,
  tinit=2*normM;  xinit=x0;
end



options=[1e-2, 0, 1e5, 5, 1];
[alpha,xinit]=gevp(lmis,1+2*(nargin>12),options,tinit,xinit,target);

if isempty(xinit),
  error(sprintf([' The margin is below 1e-4:\n' ...
    '    Scale the uncertainty bound down for more accuracy']));
end

D=dec2mat(lmis,xinit,1); D=D(1:n,1:n)+j*D(1:n,n+1:2*n);
if isG, G=dec2mat(lmis,xinit,2); G=G(1:n,1:n)+j*G(1:n,n+1:2*n); end




