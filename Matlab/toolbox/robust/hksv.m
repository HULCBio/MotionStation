function [hsv,p,q] = hksv(a,b,c)
%HKSV Hankel singular values and grammians P, Q.
%
% [HSV,P,Q] = HKSV(A,B,C) computes reachability and observability
%    grammians P, Q, and the Hankel singular values "hsv".
%
%    For unstable system, (-a,-b,c) is used instead and
%    "hsv = [hsv_stable;hsv_unstable]".

% R. Y. Chiang & M. G. Safonov 3/86
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------
lamda = eig(a);
ra = size(a)*[1;0];
indstab = find(real(lamda) < 10.e-16);
m = length(indstab);
if m == ra       % completely stable
   p = gram(a,b);
   q = gram(a',c');
   hsv = sqrt(eig(p*q));
   [hsv,index] = sort(real(hsv));
   hsv = hsv(ra:-1:1,:);
elseif m == 0    % completely unstable
   p = gram(-a,-b);
   q = gram(-a',c');
   hsv = sqrt(eig(p*q));
   [hsv,index] = sort(real(hsv));
   hsv = hsv(ra:-1:1,:);
elseif m > 0 & m < ra
   ddummy = zeros(size(b)*[0;1],size(c)*[1;0]);
   [al,bl,cl,dl,ar,br,cr,dr,msta] = stabproj(a,b,c,ddummy);
   % stable
   pl = gram(al,bl);
   ql = gram(al',cl');
   hsvl = sqrt(eig(pl*ql));
   [hsvl,index] = sort(real(hsvl));
   hsvl = hsvl(m:-1:1,:);
   % unstable
   pr = gram(-ar,-br);
   qr = gram(-ar',cr');
   hsvr = sqrt(eig(pr*qr));
   [hsvr,index] = sort(real(hsvr));
   hsvr = hsvr(ra-m:-1:1,:);
   hsv = [hsvl;hsvr];
end
%
% -------- End of HKSV.M --- RYC/MGS
