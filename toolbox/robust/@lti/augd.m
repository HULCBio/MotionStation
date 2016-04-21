function [AD,BD1,BD2,CCD1,CCD2,DD11,DD12,DD21,DD22] = augd(varargin)
%AUGD Augmentation of diagonal scaling D(s) onto two-port state-space plant.
%
% [TSS_D] = AUGD(TSS_,SS_D) or
% [AD,BD1,BD2,CCD1,CCD2,DD11,DD12,DD21,DD22] = AUGD(A,B1,B2,C1,C2,..
% D11,D12,D21,D22,AD,BD,CCD,DD) produces a two-port augmented plant
%  TSS_D that absorbs the scaling matrices D(s) and inv(D(s))
%  such that
%                                -1
%        (TSS_D) := D(s) P(s) D(s)
%                 = MKSYS(AD,BD1,BD2,CCD1,CCD2,DD11,DD12,DD21,DD22,'tss');
%
%
%  Input Data: P = TSS_ = MKSYS(A,B1,B2,C1,C2,D11,D12,D21,D22,'tss')
%              D = SS_D = MKSYS(AD,BD,CCD,DD);

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $

% Must have nargin<3 (lti version only)
if nargin>2, error('Too many input arguments'),end


nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b1,b2,c1,c2,d11,d12,d21,d22,ad,bd,ccd,dd]=mkargs5x('tss,ss',varargin); error(emsg);

%if exist('ad')==2,ad=[];end  % This takes care empty matrix bug in eval

if min(size(ad))==0
  di=inv(dd);
  AD = a;
  BD1 = b1*di;
  BD2 = b2;
  CCD1 = dd*c1;
  CCD2 = c2;
  DD11 = dd*d11*di;
  DD12 = dd*d12;
  DD21 = d21*di;
  DD22 = d22;
else
  [ai,bi,ci,di] = ssinv(ad,bd,ccd,dd);

  %
  xd = size(ad)*[1;0];
  xp = size(a)*[1;0];
  u1 = size(b1)*[0;1];
  u2 = size(b2)*[0;1];
  y1 = size(c1)*[1;0];
  y2 = size(c2)*[1;0];

  AD = [ai        zeros(xd,xp) zeros(xd,xd);
        b1*ci     a                   zeros(xp,xd);
        bd*d11*ci bd*c1               ad];
  BD1 = [bi;b1*di;bd*d11*di];
  BD2 = [zeros(xd,u2);b2;bd*d12];
  CCD1 = [dd*d11*ci dd*c1 ccd];
  CCD2 = [d21*ci c2 zeros(y2,xd)];
  DD11 = dd*d11*di;
  DD12 = dd*d12;
  DD21 = d21*di;
  DD22 = d22;
end
%
if xsflag
   AD = mksys(AD,BD1,BD2,CCD1,CCD2,DD11,DD12,DD21,DD22,Ts,'tss');
end
%
% ------ End of LTI/AUGD.M % RYC/MGS %