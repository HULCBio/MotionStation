function [cg,ph] = dcgloci2(varargin)
%DCGLOCI2 Discrete characteristic gain/phase frequency response.
%
% [CG,PH] = DCGLOCI2(SS_, CGTYPE, W, Ts) or
% [CG,PH] = DCGLOCI2(A, B, C, D, CGTYPE, W, Ts) produces the matrix G & PH
% containing the characteristic Gain/Phase values for the discrete system
% sampled at Ts sec:
%
%                x(k+1) = Ax(k) + Bu(k)
%                y(k) = Cx(k) + Du(k)
%                                                   -1
%     with the frequency response G(z) = C(zI - A)  B + D.
% DCGLOCI calculates the eigenvalues of one of the following depending
% on the value of "cgtype" :
%
%     cgtype = 1   ----   char( G(z) )
%     cgtype = 2   ----   char( inv( G(z) ) )
%     cgtype = 3   ----   char( I + G(z) )
%     cgtype = 4   ----   char( I + inv( G(z) )
%
% Vector W contains the frequencies at which the frequency response
% is to be evaluated.  The CG and PH matrices have rows
% which correspond to the char. gain/phase in descending order.
%

% R. Y. Chiang & M. G. Safonov 6/29/87
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.11.4.3 $
% All Rights Reserved.
% -----------------------------------------------------------------------
%
nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d,cgtype,w,Ts]=mkargs5x('ss',varargin); error(emsg);

[mg] = dfreqrc(a,b,c,d,w,Ts);
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
% ----- End of DCGLOCI2.M ---- RYC/MGS 6/29/87 %


