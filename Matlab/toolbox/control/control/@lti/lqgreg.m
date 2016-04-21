function rlqg = lqgreg(kest,k,varargin)
%LQGREG  Form linear-quadratic-Gaussian (LQG) regulator
%
%   RLQG = LQGREG(KEST,K) produces an LQG regulator by 
%   connecting the Kalman estimator KEST designed with KALMAN 
%   and the state-feedback gain K designed with (D)LQR or LQRY:
%
%           +----------------------------+
%         u |                            |
%           |    +------+                |
%           +--->|      |  x_e  +----+   |
%                | KEST |------>| -K |---+-----> u
%     y -------->|      |       +----+
%                +------+
%
%   The resulting regulator RLQG has input y and generates the 
%   commands  u = -K x_e  where x_e is the Kalman state estimate
%   based on the measurements y.  This regulator should be
%   connected to the plant using positive feedback.
%
%   For discrete systems, x_e is the state estimate x[n|n-1] 
%   based on past measurements up to y[n-1].  Alternatively,
%      RLQG = LQGREG(KEST,K,'current')
%   forms the "current" regulator  u = -K x[n|n].
%
%   RLQG = LQGREG(KEST,K,CONTROLS) handles estimators that have 
%   access to additional known plant inputs Ud.  The index vector
%   CONTROLS then specifies which estimator inputs are the 
%   controls u, and the LQG regulator has input [Ud;y]:
%
%           +----------------------------+
%         u |                            |
%           |    +------+                |
%           +--->|      |  x_e  +----+   |
%    Ud -------->| KEST |------>| -K |---+-----> u
%     y -------->|      |       +----+
%                +------+
%
%   See also (D)LQR, LQRY, LQRD, KALMAN, REG, SS.

%   Author(s): P. Gahinet  8-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12.4.1 $  $Date: 2003/01/07 19:32:07 $

ni = nargin;
error(nargchk(2,4,ni));
if ~isa(kest,'ss'),
   error('The Kalman estimator KEST must be a state-space system.')
elseif hasdelay(kest),
   error('Not available for delay systems.')
elseif ~isa(k,'double') | ndims(k)>2,
   error('The gain K must be a 2-D matrix.')
end
ContEstim = isct(kest);  % 1 if estimator is continuous

% Check dimensions
[Nu,Nx] = size(k);
[kny,knu] = size(kest);
knx = size(kest,'order');
if Nx~=knx,
   error('K must have as many columns as states of KEST.')
elseif kny<Nx,
   error('Kalman estimator KEST should have more outputs than states.')
elseif Nu>knu,
   error('Row dimension of K exceeds input dimension of KEST.')
end
StateEstim = kny-Nx+1:kny;  % State estimates should be last Nx outputs of KEST

% Determine which inputs of KEST are the controls u
option = '';
switch ni
case 4
  option = 'current';
  [extra1,extra2] = deal(varargin{:});
  if isstr(extra1),
     controls = extra2;
  else
     controls = extra1;
  end
case 3
  extra = varargin{1};
  if isstr(extra),
     controls = 1:Nu;  option = 'current';
  else
     controls = extra;
  end
otherwise
  controls = 1:Nu;
end

% Check dims of CONTROLS
if any(controls<=0) | any(controls>knu),
   error('Index in CONTROLS is out of range.')
elseif length(controls)~=Nu,
   error('K must have LENGTH(CONTROLS) rows.')
end


% In discrete time, replace the estimator output x[n|n] by the 
% state x[n|n-1] unless OPTION = 'current'
if ContEstim,
   % option 'current' only meaningful for discrete systems
   option = '';
elseif length(option)==0,
   % Replace the estimator output x[n|n] by the state x[n|n-1]
   c = [zeros(kny-Nx,Nx) ; eye(Nx)];
   d = zeros(kny,knu);
   set(kest,'c',c,'d',d);
end

% Close the loop 
%             +------+
%      +------|  -K  |<----+
%   u  |      +------+     | 
%      |                   |
%      |       +------+    |
%      +------>|      |--- | ---> y_e
%   Ud ------->| KEST |    |
%    y ------->|      |----+----> x_e
%              +------+
%
% RE: the state estimates should be the last Nx outputs
if strcmp(option,'current'),
   % Detect algebraic loop when OPTION = 'current'
   [ae,be,ce,de] = ssdata(kest);
   Dux = de(StateEstim,controls);      % x[n|n] = ... + Dux * u[n] (Dux=-MD)
   if rcond(eye(Nu)+k*Dux) < 1e3*eps,
      error('I-KMD is singular: "current" LQG regulator is non causal.')
   end
end
rlqg = feedback(kest,k,controls,StateEstim);

% Keep control names and label all outputs as Controls
kss = ss(-k);
if Nu,  
   kss.OutputGroup = struct('Controls',1:Nu);  
end
kss.OutputName = kest.InputName(controls);
     
% Get rid of u,y_e and add gain -K so that output is u = -K x_e
NotControls = 1:knu;
NotControls(controls) = [];
rlqg = kss * rlqg(StateEstim,NotControls);

