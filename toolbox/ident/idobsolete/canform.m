function ms = canform(pseudobsind,nu,dkx)
%CANFORM Constructs canonical form model structures.
%   OBSOLETE function. Use IDSS and the Proporty/Value par 'SSParameterization'/'Canonical'.
%
%   MS = CANFORM(ORDERS,NU,DKX)
%
%   MS:     The resulting model structure, to be used e.g. in MS2TH
%   ORDERS: Defines the model order and structure. This is a
%           vector with as many entries as there are output channels.
%           The model order is then the sum of these entries. Basically, 
%           ORDERS(k) gives the number of delays of output # k that are 
%           used by the model, and a canonical parametrization is built
%               up accordingly. (These are the pseudo-observability indices, 
%           defining the structure. See e.g. Ljung(1987), Appendix 4.A.)
%   NU:     The number of inputs
%   DKX:    Determines whether to estimate the K (Kalman gain/Noise model),
%           D (Direct term from input to output) and X0 (initial state) 
%           elements in the state-space model. Enter as DKX = [D, K, X0],
%           where entry '0' means not to estimate, but fix to 0, while
%           '1' means that the corresponding matrix is estimated.
%           To define an arbitrary input delay structure NK, where NK(ku) is
%           the delay from input number ku to any of the outputs, let
%           DKX=[D,K,X,NK]. NK is thus a row vector of length=no of input
%           channels. When NK is specified, it overrides the value of D.
%           Default: DKX = [0, 1, 0]
%
%   It may be difficult to find reasonable initial parameter estimates.
%   In that case, use CANSTART.
%
%   See also MS2TH and MODSTRUC

%   L. Ljung 10-2-1990, 21-7-1994
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.7 $ $Date: 2001/04/06 14:21:37 $

if nargin<2
   disp('Usage: TH = canform(ORDERS,NU)')
   disp('       TH = canform(ORDERS,NU,DKX)')
   return
end
if nargin<3,dkx=[];end,if isempty(dkx),dkx=[0,1,0];end
if length(dkx)<2,dkx(1)=0;dkx(3)=0;end
if length(dkx)<3,dkx(3)=0;end
if length(dkx)>3
   nk=dkx(4:length(dkx));
   if length(nk)~=nu
      disp(str2mat('If you specify a delay structure in DKX,',...
                    'you must give the delay for each input,',...
                    ' i.e. DKX must have length 3+no of inputs.'));
      error(' ')
   end
   if any(nk~=fix(nk))|any(nk<0)
      error(['The delays must be non-negative integers.'])
   end
   if any(nk==0),dkx(1)=1;else dkx(1)=0;end
elseif dkx(1), nk=zeros(1,nu);
else nk=ones(1,nu);
end
if nu==0&dkx(2)==0
   error('For a time-series model, the K-matrix has to be estimated.')
end
if any(pseudobsind<0),
  error('All order indices must be non-negative.')
end
ny=length(pseudobsind);
nx=sum4vms(pseudobsind);
if nargin < 4, dopt=[];end
if nargin < 3 x0=zeros(nx,1);end
ps = pseudobsind(find(pseudobsind>0));
r1=cumsum(pseudobsind);
r=cumsum(ps);

a=[zeros(nx,1),[eye(nx-1);zeros(1,nx-1)]];

for kl=r
   a(kl,:)=NaN*ones(1,nx);
end
b=NaN*ones(nx,nu);
if dkx(2),k=NaN*ones(nx,ny);else k=zeros(nx,ny);end
c=zeros(ny,nx);
zerops=find(pseudobsind==0);
nonzer=find(pseudobsind>0);

r1=[0,r1];

for kl=nonzer
   c(kl,r1(kl)+1)=1;
end

if ~isempty(zerops),c(zerops,:)=NaN*ones(length(zerops),nx);end
d=zeros(ny,nu);
if dkx(1)
   d(:,find(nk==0))=NaN*ones(ny,length(find(nk==0)));
end
if dkx(3)
   x0=NaN*ones(nx,1);
else
   x0=zeros(nx,1);
end
if any(nk>1),[a,b,c,d,k,x0]=ssssaux('expand',a,b,c,d,k,x0,nk);end
ms=modstruc(a,b,c,d,k,x0);

