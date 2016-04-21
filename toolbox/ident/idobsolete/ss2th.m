function th = ss2th(th,psobs,dkx)
%SS2TH  Produces a parameterized state-space model.
%   OBSOLETE function. Use IDSS or PEM directly.
%
%       THS = SS2TH(TH,ORDERS,DKX)
%
%       TH:  Original model in THETA format
%       THS: Model in THETA format, corresponding to a state
%            space representation in a canonical form corresponding
%            th 'pseudobservability indexes' ORDERS. 
%
%   Nominal parameter values are taken from the nominal or fixed values in TH.
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
%
%       If K, D and/or X0 is all zero in TH, this will make these matrices fixed 
%       to zero also in THS.
%       If ORDERS is omitted, a default choice is made.
%   If DKX is omitted, the default is decided from the values of TH,
%
%       See also CANFORM, CANSTART and MS2TH

%   L. Ljung 10-10-93
%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.8 $ $Date: 2001/04/06 14:21:40 $

if nargin < 1
  disp('Usage: THS = SS2TH(TH)')
  disp('       THS = SS2TH(TH,ORDERS,DKX)')
  return
end
if nargin<2, psobs='Auto';end
if nargin<3
  dkx=[0,1,0];
end

th = idss(th);
nu = size(th,'nu');
set(th,'CanonicalIndices',psobs,'SSParamerization','Canonical');
if dkx(2)
   set(th,'DisturbanceModel','Estimate');
end
if dkx(3)
   set(th,'InitialState','Estimate');
end
if dkx(1)
   set(th,'nk',zeros(1,nu));
end
