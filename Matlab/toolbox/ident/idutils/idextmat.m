function ff = idextmat(f,fi,Ts)
%IDEXTMAT Extends matrices for idpoly objects
%
%   FF = IDEXTMAT(F,FI,Ts)
%
%   The matrix F is extended by adding the rows of FI, left or right
%   shifted according to Discrete or Continuous-Time standards.

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.1 $ $Date: 2002/09/04 15:50:27 $

[nu,nf] = size(f);
[nu1,nf1] = size(fi);
nfm = max(nf,nf1);
ff = zeros(nu+nu1,nfm);
if Ts==0 % right alignment
    ff(1:nu,nfm-nf+1:nfm) = f;
    ff(nu+1:nu+nu1,nfm-nf1+1:nfm) = fi;
else
     % left alignment
     ff(1:nu,1:nf) = f;
     ff(nu+1:nu+nu1,1:nf1) = fi;
 end
