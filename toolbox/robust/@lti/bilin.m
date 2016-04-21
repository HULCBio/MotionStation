function [AB,BB,CB,DB] = bilin(varargin)
%BILIN State-space bilinear transform.
%
% [SS_B] = BILIN(SS_,VERS,METHOD,AUG) or
% [AB,BB,CB,DB] = BILIN(A,B,C,D,VERS,METHOD,AUG) performs a frequency
%      plane bilinear transform:
%          az + d                           d - bs
%    s = ---------  (if vers = 1); or z = ----------  (if vers = -1)
%          cz + b                           cs - a
%   such that
%                    -1                                -1
%       G(s) = C(Is-A) B + D <-------> G(z) = Cb(Iz-Ab)  Bb + Db
% --------------------------------------------------------------------------
%   'Tustin' ----- Tustin Transform (s = 2(z-1)/T(z+1), aug = T).
%   'P_Tust' ----- Prewarped Tustin (s = w0(z-1)/tan(w0*T/2)(z+1),
%                                  aug = (T,w0), w0:prewarped freq.)
%   'BwdRec' ----- Backward Rectangular (s = (z-1)/Tz, aug = T).
%   'FwdRec' ----- Forward Rectangular (s = (z-1)/T, aug = T).
%   'S_Tust' ----- Shifted Tustin (2(z-1)/T(z/sh+1), aug = (T,sh),
%                                sh: shifted circle coeff.).
%   'Sft_jw' ----- Shifted jw-axis Bilinear (aug = (b1,a1), circle coeff.).
%   'G_Bili' ----- General Bilinear (s = (az+d)/(cz+b), aug = (a,b,c,d)).
%       (Note: these options are NOT case sensitive anymore!)
% -------------------------------------------------------------------------

% R. Y. Chiang & M. G. Safonov 7/15/88
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $

[emsg,nag1,xsflag,Ts,A,B,C,D,vers,method,aug]=mkargs5x('ss',varargin); error(emsg);
omethod=method;

method = lower(method);
method(find(method=='_'))=''; % Remove _'s from F.
method(find(method==' '))=''; % Remove spaces from F.

%
% ---- Transform Identification :
%
if issame(method,'tustin')
   T = aug;
   if vers == 1
      a = 2/T; b = 1; c = 1;  d = -a;
      if Ts, error(['System must have sampling time Ts=0 for s -> z ' omethod ' transformation']),end; Ts=T;
   else
      a = T/2; b = 1; c = -a; d = 1;
      if ~Ts, error(['System must discrete-time for z -> s ' omethod ' transformation']),end; Ts=0;
   end
elseif issame(method,'ptust')
   T = aug(1,1);
   w0 = aug(1,2);
   if vers == 1
      a = w0/tan(w0*T/2); b = 1; c = 1;    d = -a;
      if Ts, error(['System must have sampling time Ts=0 for s -> z ' omethod ' transformation']),end; Ts=T;
   else
      a = tan(w0*T/2)/w0; b = 1; c = -a;   d = 1;
      if ~Ts, error(['System must discrete-time for z -> s ' omethod ' transformation']),end; Ts=0;
   end
elseif issame(method,'bwdrec')
   T = aug;
   if vers == 1
      a = 1;    b = 0; c = T;    d = -1;
      if Ts, error(['System must have sampling time for s -> z ' omethod ' transformation']),end; Ts=T;
   else
      a = 0;    b = 1; c = -T;   d = 1;
      if ~Ts, error(['System must discrete-time for z -> s ' omethod ' transformation']),end; Ts=0;
   end
elseif issame(method,'fwdrec')
   T = aug;
   if vers == 1
      a = 1;   b = T; c = 0;     d = -1;
      if Ts, error(['System must have sampling time for s -> z ' omethod ' transformation']),end; Ts=T;
   else
      a = T;  b = 1;  c = 0;     d = 1;
      if ~Ts, error(['System must discrete-time for z -> s ' omethod ' transformation']),end; Ts=0;
   end
elseif issame(method,'stust')
   T = aug(1,1);
   sh = aug(1,2);
   if vers == 1
      a = 2/T; b = 1; d = -a; c = 1/sh;
      if Ts, error(['System must have sampling time Ts=0 for s -> z ' omethod ' transformation']),end; Ts=T;
   else
      a = 1; b = 2/T; c = -1/sh; d = b;
      if ~Ts, error(['System must discrete-time for z -> s ' omethod ' transformation']),end; Ts=0;
   end
elseif issame(method,'sftjw')
   xx = aug;
   if vers == 1
      a = 1; b = 1; c = 1/xx(1,1); d = xx(1,2);
   else
      a = -1; b = -1; c = 1/xx(1,1); d = xx(1,2);
   end
elseif issame(method,'gbili')
   xx = aug;
   if vers == 1
      a = xx(1,1); b = xx(1,2); c = xx(1,3);, d = xx(1,4);
   else
      a = -xx(1,2); b = -xx(1,1); c = xx(1,3); d = xx(1,4);
   end
else
    error(['Method ' omethod ' not recognized'])
end
%
% ---- State-Space Representation :
%
[ra,ca] = size(A);
iidd = inv(a*eye(ra)-c*A);
AB = (b*A-d*eye(ra))*iidd;
BB = (a*b-c*d)*iidd*B;
CB = C*iidd;
DB = D + c*C*iidd*B;
%
if xsflag,
   AB = mksys(AB,BB,CB,DB,Ts);
end
%
% ------- End of BILIN.M --- RYC/MGS 7/15/1987 ---%