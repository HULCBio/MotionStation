function [ag,bg1,bg2,cg1,cg2,dg11,dg12,dg21,dg22,at,bt1,bt2,ct1,ct2,dt11,dt12,dt21,dt22]=sectf(varargin);
%SECTF Sector transformation.
%
% [SYSG,SYST] = SECTF(SYSF,SECF,SECG); or
% [AG,BG,CG,DG,AT,BT1,...,DT21,DT22]=SECTF(AF,BF,CF,DF,SECF,SECG); or
% [AG,BG1,...,DG22,AT,BT1,...,DT21,DT22]=SECTF(AF,BF1,...,DF22,SECF,SECG);
%
% SECTF computes the sector transformed system G(s) such that I/O pairs
% (Ug,Yg) of G(s) are in sector SECG if and only the corresponding M-vector
% I/O pairs (Uf,Yf) of F(s) are in are in sector SECF.  Also computed is
% a linear fractional transformation T(s) such that SYSG = LFTF(SYST,SYSF).
% INPUTS: SYSF -- A SYSTEM in either 'ss' or 'tss' form; or the
%                 corresponding list of matrices AF,BF,CF,DF or
%                 AF,BF1,BF2,CF1,CF2,DF11,DF12,DF21,DF22; if 'tss'
%                 form then the sector transform is applied to (Uf1,Yf1).
%   SECF,SECG  -- Sectors in one of the following forms:
%         Form:                       Corresponding Sector:
%         [A,B] or [A;B]              0> <Y-AU,Y-BU>
%         [A,B] or [A;B]              0> <Y-diag(A)U,Y-diag(B)U>
%         [SEC11 SEC12;SEC21,SEC22]   0> <SEC11*U+SEC12*Y,SEC21*U+SEC22*Y>
%   where A,B are scalars in [-Inf,Inf] or square MxM matrices or M-vectors;
%   and SEC=[SEC11,SEC12;SEC21,SEC22] is either a matrix or a 'tss' SYSTEM
%   with either 1x1 (scalar) or MxM blocks SEC11,SEC12,SEC21,SEC22.
% OUTPUTS:  SYSG -- G(s) in  same form as F(s) (e.g., 'ss' or 'tss' form)
%           SYST -- T(s) in 'tss'form; or list of matrices AT,BT1,...,DT22.
%
% See also LFTF, SEC2TSS and MKSYS.


% R. Y. Chiang & M. G. Safonov 7/1/87, 3/7/92
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $

%% Was
%% function [ag,bg1,bg2,cg1,cg2,dg11,dg12,dg21,dg22,at,bt1,bt2,ct1,ct2,dt11,dt12,dt21,dt22]=sectf(Z1,Z2,Z3,Z4,Z5,Z6,Z7,Z8,Z9,Z10,Z11,Z12,Z13,Z14,Z15,Z16,Z17,Z18,Z19,Z20,Z21,Z22,Z23,Z24,Z25,Z26,Z27);

% Must have nargin<3 (lti version only)
if nargin>3, error('Too many input arguments'),end


nag11=nargin;
nag2=nargout;
[junk,junk,Ts,Z1,Z2,Z3,Z4,Z5,Z6,Z7,Z8,Z9,Z10,Z11,Z12,Z13,Z14,Z15,Z16,Z17,Z18,Z19,Z20,Z21,Z22,Z23,Z24,Z25,Z26,Z27]=mkargs5x('',varargin);
ssflag=0;
secfflag=0;
secgflag=0;
sysflag=issystem(varargin{1});

%INITIALIZE ALL POSSIBLE INARGS TO EMPTY FOR V5 COMPATIBILITY

b=[];
c=[];
d=[];

a=[];   b1=[];  b2=[];
c1=[]; d11=[]; d12=[];
c2=[]; d21=[]; d22=[];

 af=[];  bf1=[]; bf2=[];
cf1=[]; df11=[]; df12=[];
cf2=[]; df21=[]; df22=[];

ag=[];   bg1=[];  bg2=[];
cg1=[]; dg11=[]; dg12=[];
cg2=[]; dg21=[]; dg22=[];



if nag11==3,
% If SYSG is 'ss' statespace form, set SSFLAG; also verify nag11 is valid:
  if sysflag,
    if ~issame(branch(varargin{1},'ty'),'tss'),  % If varargin{1} is not a 'tss', assume it is 'ss' (or will be converted to 'ss' by MKARGS)
       ssflag=1;
    end
  else
    error('First of 3 input arguments should be a SYSTEM')
  end
elseif nag11==6  | nag11==14 | nag11==22,
  % G(s) in a,b,c,d form or 'ss' form
  ssflag=1;
elseif nag11==11 | nag11==19 | nag11==27,
  % G(s) in a,b1,b2,c1,...,d21,d22 form or 'tss' form
  ssflag=0;
elseif nag11==5
  % Case of old  1988 version of sectf--> call sectf88.m:
  [ag,bg1,bg2,cg1]=sectf88(varargin{:});
  return
elseif nag11==8,
  % Case of old  1988 version of sectf--> call sectf88.m:
  [ag,bg1,bg2,cg1]=sectf88(varargin{:});
  return
else
  error('Number of input arguments must be either 3,5,6,8,11,14,19,22 or 27 (depending on data format)')
end

% If nag11 is 11,14 or 19 and varargin{1} is not a system, then one and only one of the two arguments SECF and SECG is a 'tss'
% Depending on SSFLAG  modify INARGS; then call MKARGS.M

if ssflag,
   % INARGS for case in which SYSG is 'ss' state-space:
   % inargs='(a,b,c,d,af,bf1,bf2,cf1,cf2,df11,df12,df21,df22,ag,bg1,bg2,cg1,cg2,dg11,dg12,dg21,dg22)';
   % eval(mkargs(inargs,nag11,'ss,tss'))
   [emsg,nag1,xsflag,Ts,a,b,c,d,af,bf1,bf2,cf1,cf2,df11,df12,df21,df22,ag,bg1,bg2,cg1,cg2,dg11,dg12,dg21,dg22]=mkargs5x('ss,tss',varargin); error(emsg);
else
   % INARGS for case in which SYSG is 'tss' two-port state-space:
   % inargs='(a,b1,b2,c1,c2,d11,d12,d21,d22,af,bf1,bf2,cf1,cf2,df11,df12,df21,df22,ag,bg1,bg2,cg1,cg2,dg11,dg12,dg21,dg22)';
   % eval(mkargs(inargs,nag11,'tss'))
   [emsg,nag1,xsflag,Ts,a,b1,b2,c1,c2,d11,d12,d21,d22,af,bf1,bf2,cf1,cf2,df11,df12,df21,df22,ag,bg1,bg2,cg1,cg2,dg11,dg12,dg21,dg22]=mkargs5x('tss',varargin); error(emsg);

end

nag3=nag1;  % Number of input arguments after expansion

% Now determine DIM of T(s) from SYSG:
if ssflag,
  d11=d;
end
dim = max(size(d11));

% Make sure F(s) is square:
if dim ~= min(size(d11)),
  error(['Your system (F(s) is non-square:' 13 10 '     Sector transformation is only defined for a square systems'])
end

% If sectors SECG and SECF are not dynamical (i.e., if  af,bf1,...
% df22,ag1,bg1,...,dg22 not specified in the input) determine
% equivalent dynamical sectors using SEC2TSS:
if nag3==6 | nag3==11,          % If  SECF and SECG were both not dynamical
  secf=af;    % SECF is notation for SECF
  secg=bf1;   % SECG is notation for SECG
  % Now transform constant sectors SECF and SECG to standard
  % dynamical two-port state space ('tss') form:
  [af,bf1,bf2,cf1,cf2,df11,df12,df21,df22]=sec2tss(secf,dim);
  [ag,bg1,bg2,cg1,cg2,dg11,dg12,dg21,dg22]=sec2tss(secg,dim);
elseif (nag3==14 | nag3==19)
  % txtf = ['secfflag=issystem(Z' nag11-1 ')'];
  % eval(txtf)
  secfflag=issystem(varargin{nag11-1});
  % txtg = ['secgflag=issystem(Z' nag11 ')'];
  % eval(txtg)
  secgflag=issystem(varargin{nag11});
  if secfflag | min(size(ag))<max(size(ag)) | max(size(ag))~=max(size(df22))
  % sufficient conditions for SECG to be constant and SECF dynamical
    secg=ag;
    [ag,bg1,bg2,cg1,cg2,dg11,dg12,dg21,dg22]=sec2tss(secg,dim);
  elseif min(size(af))<max(size(af)) | secgflag
  % sufficient conditions for SECF to be constant and SECG dynamical
    dg22=ag
    dg21=df22
    dg12=df21;
    dg11=df12;
    cg2=df11;
    cg1=cf2;
    bg2=cf1;
    bg1=bf2;
    ag=bf1;
    secf=af;
  else
    error('Try specifying dynamical SECG or SECF in SYSTEM format')
  end
elseif ~(nag3==22 | nag3==27)
  error('Incorrect number or type of input arguments')
end

% Do some cursory checks on dimensional compatibility
dimf=max(size(df11));
dimg=max(size(dg11));
if min([dimf,dimg])==1,
  dim=max([dimf,dimg]); % then determine the default value
elseif dimf==dimg,       % of DIM from SECF and SECG
   dim=dimf;
else
  error('SECF and SECG must have compatible dimensions')
end




% Do some cursory dimensionality checks
tempf=[size(df11),size(df12),size(df21),size(df22)];
tempg=[size(dg11),size(dg12),size(dg21),size(dg22)];
if min(tempf)~=max(tempf)
   error('Something wrong with the dimensions of input SECF')
end
if min(tempg)~=max(tempg)
   error('Something wrong with the dimensions of input SECG')
end
if nag3<19,
  if dimf~=dimg & min([dimf,dimg])>1,
     error('SECF and SECG I/O dimensions must be equal if greater than 2'),
  end
elseif nag3==19
  if dimf~=dim & dimf>1,
     error('SECF must have I/O dimension equal to either 1 or DIM')
  end
  if dimg~=dim & dimg>1,
     error('SECG must have I/O dimension equal to either 1 or DIM')
  end
end

[m,junk]=size(d11);
[nf,junk]=size(af);
[ng,junk]=size(ag);
nt=nf+ng;

% We now have the following variables needed to compute T(s),G(s):
%   dim                  min([size(DG11),size(DF11])
%   nf                   the state-dimension of the `tss' system SECF
%   ng                   the state-dimension of the `tss' system SECG
%   nt = nf +ng          the state-dimension of T(s)
%   (a,b,c,d) or (a,b1,b2,c1,c2,d11,d12,d21,d22);   from SS_1 or TSS_1
%   af,bf1,bf2,cf1,cf2,df11,df12,df21,df22,'tss';   from SECF
%   ag,bg1,bg2,cg1,cg2,dg11,dg12,dg21,dg22,'tss';   from SEC2
% Further all of the `d' matrices are square and of size mxm
% and af is (nf)x(nf) and ag is (ng)x(ng).

% Using the equality SECF*[uf;yf] - SECG*[ug;yg] = 0 we obtain
% the linear equation array:
%     xg       xf       ug      yf      yg     uf
%--------------------------------------------------
% -Is+ag        0      bg1       0     bg2     0   = 0
%      0   -Is+af        0     bf2       0    bf1  = 0
%    cg1     -cf1     dg11   -df12    dg12  -df11  = 0
%    cg2     -cf2     dg21   -df22    dg22  -df21  = 0

% Solving the above array for the state-space (AT,BT,CT,DT) of the 2Mx2M
% transfer function T(s) from [ug;yf] to [yg;uf], and partitioning to
% obtain the two-port state-space (AT,BT1,BT2,CT1,CT2,DT11,DT12,DT21,DT22):


TEMP =[  dg12  -df11
         dg22  -df21 ];

if rank(TEMP)<2*dim,
   error('Transform is ill-conditioned--try perturbing SECF or SECG')
end


dt = -TEMP\[dg11,-df12;dg21,-df22];


% Partition DT:
u1=1:dim;
u2=dim+1:2*dim;
dt11=dt(u1,u1);
dt12=dt(u1,u2);
dt21=dt(u2,u1);
dt22=dt(u2,u2);

if nt>0,
  % compute AT,BT,CT:
  ct = -TEMP\[cg1, -cf1;cg2,  -cf2];
  TEMP = diagmx(bg2,bf1);
  at =  diagmx(ag,af)+ TEMP*ct;
  bt =  diagmx(bg1,bf2) + TEMP*dt;

  % Partition  BT,CT
  bt1=bt(:,u1);
  bt2=bt(:,u2);
  ct1=ct(u1,:);
  ct2=ct(u2,:);
else
   at=[];  bt1=[];  bt2 =[];
  ct1=[];
  ct2=[];
end

% Now if the system is SISO and DIM is greater than one,
% compute a realization for
%          T(s) = [T11(s)*eye(DIM) T12(s)*eye(DIM)
%                  T21(s)*eye(DIM) T22(s)*eye(DIM)]


if max(size(dt11))==1 & dim>1,
  as =at ;   bs1 = bt1 ; bs2 =  bt2;
  cs1=ct1;   ds11= dt11; ds12= dt12;
  cs2=ct2;   ds21= dt21; ds22= dt22;
  for i=2:dim,
     at =diagmx(as ,at ); bt1 =diagmx(bs1, bt1 ); bt2 =diagmx(bs2 ,bt2 );
     ct1=diagmx(cs1,ct1); dt11=diagmx(ds11,dt11); dt12=diagmx(ds12,dt12);
     ct2=diagmx(cs2,ct2); dt21=diagmx(ds21,dt21); dt22=diagmx(dt22,dt22);
  end
end

%% Fixed empty matrix dimensions for V5 compatibility:

%%  Fix at, bt1,bt2,ct1,etc.:
[xt,junk]=size(at);
[yt1,ut1]=size(dt11);
[yt2,ut2]=size(dt22);
if xt==0,
   bt1=zeros(0,ut1);
   bt2=zeros(0,ut2);
   ct1=zeros(yt1,0);
   ct2=zeros(yt2,0);
end
if yt1==0,
   ct1=zeros(0,xt);
   dt12=zeros(0,ut2);
end
if yt2==0,
   ct2=zeros(0,xt);
   dt21=zeros(0,ut1);
end
if ut1==0,
   bt1=zeros(xt,0);
   dt21=zeros(yt2,0);
end
if ut2==0,
   bt2=zeros(xt,0);
   dt12=zeros(yt1,0);
end


%%  Fix sizes of empties in [a, b1,b2,c1,...] and [a,b,c,d]:
[xt,junk]=size(a);
[yt1,ut1]=size(d11);
[yt2,ut2]=size(d22);
[yy,uu]=size(d);
if xt==0,
   b1=zeros(0,ut1);
   b2=zeros(0,ut2);
   c1=zeros(yt1,0);
   c2=zeros(yt2,0);
    b=zeros(0,uu);
    c=zeros(yy,0);
end
if yt1==0,
   c1=zeros(0,xt);
   d12=zeros(0,ut2);
end
if yt2==0,
   c2=zeros(0,xt);
   d21=zeros(0,ut1);
end
if ut1==0,
   b1=zeros(xt,0);
   d21=zeros(yt2,0);
end
if ut2==0,
   b2=zeros(xt,0);
   d12=zeros(yt1,0);
end




% Compute G(s) = LFTF(T(s),F(s))
% (This means overwriting values of ag,bg1,...,dg22)

if ssflag,
  [ag,bg,cg,dg]=lftf(at,bt1,bt2,ct1,ct2,dt11,dt12,dt21,dt22,a,b,c,d);
  if sysflag,  % If input F(s) was in SYSTEM form:
    ag=mksys(ag,bg,cg,dg,Ts);
    if nag2>1,         % if nargout==2, convert T(s) tp SYSTEM
      bg1=mksys(at,bt1,bt2,ct1,ct2,dt11,dt12,dt21,dt22,Ts,'tss');
    end
  elseif nag2==4 | nag2==13 % Need to re-order outputs
    bg1=bg;
    bg2=cg;
    cg1=dg;
    if nag2==13,
      cg2 =at  ;
      dg11=bt1 ;
      dg12=bt2 ;
      dg21=ct1 ;
      dg22=ct2 ;
      at  =dt11;
      bt1 =dt12;
      bt2 =dt21;
      ct1 =dt22;
    end
  else
    error('Number of output arguments should be 1,2,4, or 13')
  end
else
  [ag,bg1,bg2,cg1,cg2,dg11,dg12,dg21,dg22]=...
   lftf(at,bt1,bt2,ct1,ct2,dt11,dt12,dt21,dt22,a,b1,b2,c1,c2,d11,d12,d21,d22);
  if sysflag,  % If input F(s) was SYSTEM form:
    ag=mksys(ag,bg1,bg2,cg1,cg2,dg11,dg12,dg21,dg22,Ts,'tss');
  if nag2>1,         % if nargout==2, convert T(s) tp SYSTEM
    bg1=mksys(at,bt1,bt2,ct1,ct2,dt11,dt12,dt21,dt22,Ts,'tss');
  end
  end
end


% ----------- End of LTI/SECTF.M --------RYC/MGS 1988 (REV. 03/06/92)