function th = canstart(z,pobs,nu,dkx,auxord)
%CANSTART State-space model with initial parameter estimates.
%   OBSOLETE function. Use N4SID or PEM instead.
%
%   THETA = CANSTART(Z,ORDERS,NU,DKX,AUXORD)
%   
%   THETA:  The resulting model, parametrized according to the orders
%           and with initial parameter estimates calculated
%           from data. No model covariances are given.
%   Z :     The output-input data [y u], with each input/output component
%           as a column vector.
%   ORDERS: The model order.  Optionally this argument can be given as a
%           vector with as many entries as there are output channels.
%           The model order is then the sum of these entries. Basically, 
%           ORDERS(k) gives the number of delays of output # k that are 
%           used by the model, and a canonical parametrization is built
%               up accordingly.
%   NU:     The number of inputs.
%   DKX: This is a vector defining the structure: DKX =[D,K,X]
%           D=1 indicates that a direct term from input to output will be 
%               estimated, while D=0 means that a delay from input to output
%           is postulated.
%       K=1 indicates that the K-matrix is estimated, while K=0 means that 
%               K will be fixed to zero. 
%           X=1 indicates that the initial state is estimated, X=0 that the
%           initial state is set to zero.
%           To define an arbitrary input delay structure NK, where NK(ku) is
%       the delay from input number ku to any of the outputs, let
%       DKX=[D,K,X,NK]. NK is thus a row vector of length=no of input
%       channels. When NK is specified, it overrides the value of D.
%           Default: DKX = [0, 1, 1]
%   AUXORD: The auxiliary order to be used by N4SID.
%   THETA is just an initial estimate of the system, and could be further
%         improved by TH = PEM(z,THETA);
%
%   See also N4SID, PEM, THETA.

%   L. Ljung 21-9-90,9-26-93
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.9 $ $Date: 2001/04/06 14:21:37 $

if nargin<3
   disp('Usage: TH = CANSTART(Z,ORDERS,NU)')
   disp('       TH = CANSTART(Z,ORDERS,NU,DKX,AUXORD)')
   return
end
if nargin<5,auxord=[];end
if nargin>3,
   if isstr(dkx),if strcmp(dkx,'oe'),dkx=[0,0,1];else dkx=[0,1,1];end,end
end
% The above is to accomodate the old syntax.
if nargin<4,dkx=[];end,if isempty(dkx),dkx=[0,1,1];end
if length(dkx)<2,dkx(1)=0;dkx(3)=1;end
if length(dkx)<3,dkx(3)=1;end
dkxn4=dkx;
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
   dkxn4=[dkx(1:3),1-(nk==0)];
elseif dkx(1), nk=zeros(1,nu);
else nk=ones(1,nu);
end
if isa(z,'iddata')
   y = pvget(z,'OutputData');
   u = pvget(z,'InputData');
   z = [y{1},u{1}];
end

[Ncap,nz]=size(z);

if nu==0&dkx(2)==0
   error('For a time-series model, the K-matrix has to be estimated.')
end
psobs=pobs;
if any(psobs<0)
   error('The order indices must be non-negative.')
end
ny=length(pobs);
if ny==1, 
  ny=nz-nu;
  if ny>1
     ind1=floor(pobs/ny);
     for kc=1:ny-1
       psobs(kc)=ind1;
     end
     psobs(ny)=pobs-sum(psobs);
   end
end  

if nz~=nu+ny|ny<1, error(['The number of inputs and outputs in the data vector is not',...
' consistent with the number of observability indices and the number of inputs.']),end
delayu=find(nk>1);
if ~isempty(delayu)
  zt=z(max(nk):Ncap,:);
  for ku=delayu(:)'
    zt(:,ny+ku)=z(max(nk)-nk(ku)+1:Ncap+1-nk(ku),ny+ku);
  end
  z=zt;
end

[Ncap,nz]=size(z);

th = n4sid(z,sum(psobs),length(psobs),auxord,dkxn4);
if isempty(th),return,end
th = ss2th(th,psobs,dkx);

% XXXX REVISIT
% This indicates that CANSTART created the object..
% th(2,7)=24;

