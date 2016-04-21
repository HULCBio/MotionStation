function [cg,ph] = cgloci2(varargin)
%CGLOCI2 Characteristic gain/phase Frequency Response for continuous system.
%
% [CG,PH] = CGLOCI2(SS_,cgtype,W) or
% [CG,PH] = CGLOCI2(A, B, C, D, CGTYPE, W) produces the matrix CG & PH
% containing the characteristic Gain/Phase values for the system
%                .
%                x = Ax + Bu
%                y = Cx + Du
%                                                   -1
%     with the frequency response G(jw) = C(jwI - A)  B + D.
% CGLOCI calculates eigenvalues of one of the following depending on the
% value of "cgtype":
%
%     cgtype = 1   ----   G(jw)
%     cgtype = 2   ----   inv(G(jw))
%     cgtype = 3   ----   I + G(jw)
%     cgtype = 4   ----   I + inv(G(jw))
%
% Vector W contains the frequencies at which the frequency response
% is to be evaluated.  The CG and PH matrices have rows which
% correspond to the characteristic gain/phase in descending order.

% R. Y. Chiang & M. G. Safonov 6/29/87
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.

nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d,cgtype,w]=mkargs5x('ss',varargin); error(emsg);

% discrete case (call DCGLOCI2)   
if Ts, 
   [cg,ph] = dcgloci2(varargin{:},abs(Ts));
   return
end   

% continuous case
[mg] = freqrc(a,b,c,d,w);
[rmg,cmg] = size(mg);
[rb,cb] = size(b);
[rc,cc] = size(c);
gg = ones(rc,cb);
cg = zeros(rc,length(w));
ph = cg;
for is = 1 : cmg
  gg(:) = mg(:,is);
  if (cgtype == 1)
    temp = eig(gg);
    [cg(:,is),ind] = sort(abs(temp));
    ph(:,is) = 180./pi*imag(log(temp(ind)));
  end
  if (cgtype == 2)
    temp = eig(inv(gg));
    [cg(:,is),ind] = sort(abs(temp));
    ph(:,is) = 180./pi*imag(log(temp(ind)));
  end
  if (cgtype == 3)
    [tmp1,tmp2]=size(gg);
    temp = eig(eye(tmp1,tmp2)+gg);
    [cg(:,is),ind] = sort(abs(temp));
    ph(:,is) = 180./pi*imag(log(temp(ind)));
  end
  if (cgtype == 4)
    [tmp1,tmp2]=size(gg);
    temp = eig(eye(tmp1,tmp2)+inv(gg));
    [cg(:,is),ind] = sort(abs(temp));
    ph(:,is) = 180./pi*imag(log(temp(ind)));
  end
end
cg = cg(cb:-1:1,:);
ph = ph(cb:-1:1,:);
%
% ----- End of CGLOCI2.M ---- RYC/MGS 6/29/87 %
