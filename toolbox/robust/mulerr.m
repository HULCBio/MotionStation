function [cg,ph] = mulerr(a0,b0,c0,d0,a,b,c,d,w,opt)
%MULERR Multiplicative error frequency response.
%
% [CG,PH] = MULERR(A0,B0,C0,D0,A,B,C,D,W,OPT) produce a multiplicative
% error frequency response plot between two models (A0,B0,C0,D0) and
% (A,B,C,D). The optional input "opt" determines the computing methods:
%
%          OPT = 1, Singular Values
%          OPT = 2, Characteristic Gain Loci
%


% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.

if nargin < 10
   opt = 2;
end
%
j = sqrt(-1);
ls = size(w)*[0;1];
%
siz = size(d0);
g0jw = zeros(siz(1),siz(2));
gjw  = zeros(siz(1),siz(2));
%
g0jwt = freqrc(a0,b0,c0,d0,w);
gjwt  = freqrc(a,b,c,d,w);
%
for i = 1:ls
  g0jw(:) = g0jwt(:,i);
  gjw(:)  = gjwt(:,i);
  Z = (g0jw - gjw) / g0jw;
  if opt == 1
   sv = svd(Z);
   cg(:,i) = sv;
  else
   chgain = eig(Z);
   [y,ind] = sort(-abs(chgain));
   cg(:,i) = -y;
   [x,ind] = sort(-180./pi*imag(log(chgain)));
   ph(:,i) = -x;
  end
end
%
% -------- End of MULERR.M % RYC/MGS