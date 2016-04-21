function [ad,bd,cd,dd] = des2ss(varargin);
%DES2SS Convert descriptor state-space form into regular state-space form.
%
% [SS_D] = DES2SS(SS_DES,K) or
% [AD,BD,CD,DD] = DES2SS(A,B,C,D,E,K) reduces the descriptor form system
%   into the regular state-space form via SVD of the descriptor E.
%
%   Input Data: ss_des = mksys(a,b,c,d,e,'des');
%   Optional Input Data: k = dim. of the null space of E
%   Output Data: ss_d  = mksys(a,b,c,d);

% R. Y. Chiang & M. G. Safonov 1/89
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.11.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------------

% Handle LTI objects with warning and fall through to SS(SYS)
if isa(varargin{1},'lti') & nargin==1 & nargout==1,
   warning('DES2SS(SYS) is obsolete.  For LTI objects, consider using SS(SYS) instead.')
   ad=ss(varargin{1});
   return
end


nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d,e,k]=mkargs5x('des',varargin); error(emsg);

% check dimensional compatibility
[a b;c d];
[a' b;c d];
[e b;c d];
%
% find the dim. of the null space of "e"
%

rankE = rank(e);

if nag1 < 6
   k = size(a)*[1;0]-rankE;
end
%
[ns,ns]=size(a);
if ns==0,
   ad=[];   bd=[];   cd=[];   dd=d;
   return;
end
if k>ns,
    error('DES2SS error: Cannot have k>ns');
end
if k<0,
    error('DES2SS error: Cannot have k<0');
end
%
[ue,se,ve] = svd(e);
e=ue'*e*ve;
a=ue'*a*ve;
b=ue'*b;
c=c*ve;
ns1=ns-k;
%
if rankE < ns1
   error('DES2SS error: [rank(e)+k] < size(a)');
end
%
if rankE > ns1
   disp('DES2SS warning: [rank(e)+k] > size(a)');
end
%
sei2 = (inv(se(1:ns1,1:ns1)))^.5;
a11 = a(1:ns1,1:ns1);
bb1 = b(1:ns1,:);
cc1 = c(:,1:ns1);
if k>0,
   a22 = a(ns1+1:ns,ns1+1:ns);
   [ua,sa,va] = svd(a22);
   a22=sa;
   a12 = a(1:ns1,ns1+1:ns)*va;
   a21 = ua'*a(ns1+1:ns,1:ns1);
   a22i = pinv(a22);
   bb2 = ua'*b(ns1+1:ns,:);
   cc2 = c(:,ns1+1:ns)*va;
   ad = a11 - a12*a22i*a21;
   bd = bb1  - a12*a22i*bb2;
   cd = cc1 - cc2 * a22i * a21;
   dd = d - cc2 * a22i * bb2;
else
   ad=a11;
   bd=bb1;
   cd= cc1;
   dd=d;
end
if ns1 > 0
   ad= sei2*ad*sei2;
   bd= sei2*bd;
   cd= cd*sei2;
else
   ad = -1.e15*eye(ns); bd = zeros(ns,size(b)*[0;1]);
   cd = zeros(size(c)*[1;0],ns);
end
%
if xsflag
   ad = mksys(ad,bd,cd,dd,Ts);
end
%
% ------------- End of DES2SS.M --- RYC/MGS %