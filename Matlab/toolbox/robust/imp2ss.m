function [a,b,c,d,totbnd,svh] = imp2ss(varargin)
%IMP2SS System identification via impulse response (Kung's SVD algorithm).
%
% [A,B,C,D,TOTBND,SVH] = IMP2SS(Y) or
% [A,B,C,D,TOTBND,SVH] = IMP2SS(Y,TS,NU,NY,TOL) or
% [SS_,TOTBND,SVH] = IMP2SS(IMP_)
% [SS_,TOTBND,SVH] = IMP2SS(IMP_,TOL) produces an approximate
% state-space realization of a given impulse response
%                 IMP_=MKSYS(Y,TS,NU,NY,'imp')
% using the Hankel SVD method proposed by S. Kung (Proc. Asilomar
% Conf. on Circ. Syst. & Computers, 1978).  A continuous-time
% realization is computed via the inverse Tustin transform if
% TS is positive; otherwise, a discrete-time realization is returned.
%
%  INPUTS:  Y --- impulse response H1,...,HN stored rowwise
%                 Y=[H1(:)'; H2(:)'; H3(:)'; ...; HN(:)']
%  OPTIONAL INPUTS:
%           TS  ---  sampling interval (default  TS=0)
%           NU  ---  number of inputs  (default NU=1)
%           NY  ---  number of outputs (default NY= size(Y)*[1;0]/nu)
%           TOL ---  Hinfnorm of error bound (default TOL=0.01*S(1))
%  OUTPUTS: (A,B,C,D) discrete-time state-space realization
%           TOTBND  Infinity norm error bound  2*Sum([S(NX+1),S(NX+2),...])
%           SVH  Hankel singular values [S(1);S(2);... ]

% R. Y. Chiang & M. G. Safonov 8/91
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.12.4.3 $
% All Rights Reserved.

nag1 = nargin;
nag2 = nargout;

[emsg,nag1,xsflag,junk,y,ts,nu,ny,tol]=mkargs5x('imp',varargin); error(emsg);

[mm,nn] = size(y);
if nn==1,
  y=y';
  [mm,nn] = size(y);
end
nt=nn-1;

% Do defaults for TS,NU,NY and TOL
if nag1<2|isempty(ts)|isnan(ts),ts=0;end
if nag1<3,nu=1;end
if nag1<4,
  if rem(mm,nu)~=0,
    error('Incompatible Dimensions---The row dimension of Y must be divisible by NU'),
  end
  ny=mm/nu;
end


% Check dimensional compatibility:
if ny*nu~=mm,
  error('Incompatible Dimensions---Must have NY*NU = (no. of columns of Y)')
end

z=zeros(ny,nu);

% Get D matrix D=H(0)
d=z;
d(:) = y(:,1);

% Overwrite Y with Y= [H(0) H(1) ...H(nt)]
tmp=y;
m=ny;
n=nn*nu;
y=zeros(m,n);
y(:)=tmp(:);  % y = [H(0) H(1)   H(2) ... H(nt)]

% Build Hankel matrix H = [H(1)   H(2) ... H(nt)
%                          H(2)   H(3) ...   0
%                                  ...
%                          H(nt)    0        0 ]

if nu==1 & ny==1,
  h=hankel(y(2:nn));
else
   y=y(:,nu+1:n);          % throw away H(0) from y
   [m,n]=size(y);
   h=zeros(m*nt,n);        % predimension hankel
   for i=1:nt,             
      h(m*(i-1)+1:m*i,:)=y;% build the hankel, m rows at a time
      y=[y(:,nu+1:n) z];   % y= [ H(i),...,H(nt),0,...,0]
   end
end
[rh,ch]=size(h);

% Compute the SVD of the Hankel
[u,svh,v] = svd(h);
svh=diag(svh);
ns=length(svh);
if nag1<5,tol=0.01*svh(1);end

% Determine NX and TOTBND
tail=[conv(ones(ns,1),svh(:)); 0]';
tail=tail(ns:ns+ns);
nx=find(2*tail<=tol*ones(size(tail)));
nx=nx(1)-1;
totbnd=2*tail(nx+1);  % TOTBND = 2*(SVH(NX+1)+SVH(NX+2)+...+SVH(NS))


%
% Truncate and partition singular vector matrices U,V
u1 = u(1:rh-ny,1:nx);
v1 = v(1:ch-nu,1:nx);
u2 = u(ny+1:rh,1:nx);
u3 = u(rh-ny+1:rh,1:nx);
%
ss = sqrt(svh(1:nx));
invss = ones(nx,1)./ss;
%

% Kung's formula for the reduced model:
%
% The following is equivalent to UBAR = PINV(U)*[U2; 0]:
ubar = u1'*u2;
a = ubar.*(invss*ss');   % A = INV(DIAG(SS))*UBAR*DIAG(SS)
b = (ss*ones(1,nu)).*v1(1:nu,:)';  % B = DIAG(SS)*V1(1:NU,:)'
c = u1(1:ny,:).*(ones(ny,1)*ss');  % C = U1(1:NY,:)*DIAG(SS)
%
if ts>0,
  [a,b,c,d]=bilin(a,b,c,d,-1,'Tustin',ts); % convert to continuous
end

if nag2<4;
   if ts>0,  % return continuous time
      ss_ = mksys(a,b,c,d);
   elseif ts==0, % return discrete-time Ts=-1 (unspecified ts)
      ss_ = mksys(a,b,c,d,-1);
   else          % if ts<0 return discrete-time (Ts=abs(ts)>0) 
      ss_ = mksys(a,b,c,d,-ts);
   end
   a = ss_;
   b=totbnd;
   c=svh;
end
%
% -------- End of IMP2SS.M % RYC/MGS
