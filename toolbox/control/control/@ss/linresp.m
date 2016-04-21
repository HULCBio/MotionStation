function [y,t,x] = linresp(sys,Ts,u,t,x0,InterpRule)
%LINRESP   Time response simulation for (single) LTI model.
%
%   [Y,T,X] = LINRESP(SYS,TS,U,T,X0) simulates the time response
%   of the LTI model SYS to the input U,T with initial condition X0.  
%   TS specifies the model's sample time.
%
%   [Y,T,X] = LINRESP(SYS,TS,U,T,X0,INTERPRULE) explicitly specifies
%   the interpolation rule between samples (ZOH or FOH) for continuous-
%   time signals.  The default is FOH except when the signal value 
%   jumps by more than 75% of the total amplitude range between two
%   consecutive samples.
%
%   LOW-LEVEL UTILITY, CALLED BY LSIM.

%   Author: P. Gahinet, 4-98
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 06:01:18 $

dthresh = 0.75;    % threshold for discontinuity detection
tolint = 1e4*eps;  % detection of fractional delays
dt = t(2)-t(1);    % sampling time
ComputeX = (nargout>2);

% Dimensions
[ny,nu] = size(sys.d); 
nx = size(sys,'order');

% Check initial condition
if isempty(x0)
   % Set initial condition to zero if not provided
   x0 = zeros(nx,1);
elseif length(x0)~=nx, 
   error('Length of X0 does not match number of states.')
end

% Preprocessing for continuous case: determine whether to use ZOH or FOH
if Ts==0 & (nargin<6 | isempty(InterpRule)),
   % Estimate if signal is smooth or discontinuous (continuous time)
   % After normalizing amplitude, declare the input smooth if the max.
   % variation per sample does not exceeds DTHRESH% of amplitude range
   range = max(u)-min(u);
   du = abs(diff(u,[],1));
   if ~isempty(du) & all(max(du)<=dthresh*range),
      InterpRule = 'foh';
   else
      InterpRule = 'zoh';
   end
end

% Check for undersampling (issue warning with recommanded sampling)
trange = t(end)-t(1);
if Ts==0 & nx>0 & nx<100,
   % Refine sampling if system is continuous and has resonant modes 
   % beyond the nyquist frequency
   nf = pi/dt;
   r = pole(sys);
   r = r(imag(r)>0 & abs(real(r))<0.2*abs(r));   % resonant modes
   mf = max(abs(r));        % frequency of fastest resonant mode
   if mf>pi/dt/2,
       [ff,ee] = log2(pi/2/mf);
       warning(sprintf(...
           'Input signal is undersampled. Sample every %0.2g sec or faster.',...
           pow2(ee-1)))
      % Resample input
      %t0 = t;
      %dtopt = max(pi/2/mf,trange/1000);   % optimal sample period
      %OverSampling = 2^max(1,nextpow2(round(dt/dtopt)));
      %dt = dt/OverSampling;
      %t = (t(1):dt:t(end)+0.1*dt)';

      % Interpolate original input data between samples
      %if nu==0,
      %   u = zeros(length(t),0);
      %elseif strcmp(InterpRule,'foh')
         % Continuous signal: perform linear interpolation
      %   u = interp1(t0,u,t);
      %else  
         % Use zero-order hold between samples
      %   u = interp0(t0,u,t);
      %end
   end   
end
lt = length(t);

% Simulation starts
if Ts | strcmp(InterpRule,'zoh'),
   % Discrete-time model or continuous-time model with ZOH interpolation between samples
   if Ts==0,
      % ZOH discretization
      sys = c2d(sys,dt);
      x0 = [x0 ; zeros(size(sys,'order')-nx,1)];  % watch for state augmentation by C2D
   end
   
   % Extract state-space matrices and discrete delay data 
   [a,b,c,d] = ssdata(sys);
   DelayData = get(sys.lti,{'inputdelay','outputdelay','iodelay'});
   [id,od,iod] = deal(DelayData{:});
   ziod = all(~iod,1);  % input channels w/o I/O delays
   
   % Simulate with SIMRESP (LTITR)
   % First simulate channels w/o I/O delays
   [y,x] = simresp(a,b(:,ziod),c,d(:,ziod),id(ziod),od,u(:,ziod),x0);
   
   % Now simulate each input channel with internal I/O delays and 
   % superpose outputs. Note: x0 and ComputeX are both zero in this case
   for j=find(~ziod),
      tdj = id(j) + od + iod(:,j); % total delay
      tdmin = min(tdj);
      [aj,bj,cj] = smreal(a,b(:,j),c,[]);
      y = y + simresp(aj,bj,cj,d(:,j),...
                       tdmin,tdj-tdmin,u(:,j),zeros(size(aj,1),1));
   end
   
   % Extract original states (watch for augmented state dimension)
   if ComputeX,
      x = x(:,1:nx); 
   end    
   
else
   % Continuous-time system + FOH discretization.
   % FOH discretization produces the model
   %     z[k+1] = exp(A*dt) * z[k] + Bd * u[k]
   %       y[k] =     Cd    * z[k] + Dd * u[k]
   % where z[k] = x[k] - G * u[k]
   % For simulation, the initial condition must be set to z[0]=x0-G*u(1),
   % and the state trajectory is obtained as z[k] + G * u[k].
   % RE: 1) Direct FOH simulation runs into trouble for delayed input 
   % channels with nonzero u(1) (FOH implicitly interpolates the
   % input between u=0 at t=-dt and the first value u=u(1) at t=0).
   % Set u(1)=0 for such channels and simulate the response to the step 
   % offset w(t)=u(1) with ZOH method.
   %     2) The initial state map G is not available for models with
   % I/O delays. Again set u(1)=0 for such channels and use ZOH simulation
   % to capture the contribution of u(1)
   Tdio = get(sys.lti,'iodelay');  % continuous I/O delays
   
   if ~any(Tdio(:)),
       % FOH discretization without I/O delays
       % RE: Since sys is state-space, the integral input & output delays are untouched
       [sysfoh,gic] = c2d(sys,dt,'foh');
       
       % Extract SS data and discrete delays 
       [af,bf,cf,df] = ssdata(sysfoh);
       Ddelays = get(sysfoh.lti,{'inputdelay','outputdelay'});
       [id,od] = deal(Ddelays{:});
       
       % Determine which input channels require additional ZOH simulation 
       % (all channels u(1)~=0 and some nonzero total I/O delay
       % RE: 1) Input delays result in the wrong input profile on [-dt,0].  
       %     2) Similarly, for outputs delayed by tau, the FOH simulation  
       % yields y(1) = Cx[-tau] where x[-tau] is computed assuming a linear 
       % input u(t) with value 0 at t=-dt and u(1) at t=0, whereas the 
       % true input is 0 for t<0.
       zohsim = find(any(totaldelay(sys.lti),1) & u(1,:));
       if length(zohsim),
           % Save first input value
           u0 = u(1,zohsim);
           u(:,zohsim) = u(:,zohsim) - u0(ones(1,lt),:);
       end
       
       % FOH simulation 
       % RE: u(1,j) set to zero for input channels with nonzero total I/O delay.
       z0 = gic * [x0 ; u(1,:)'];
       [y,z] = simresp(af,bf,cf,df,id,od,u,z0);
       
       % Add contribution of nonzero u(1,:) for input channels with nonzero total I/O delay.
       % (ZOH simulation of response to steps u(1,ZOHSIM) with zero initial condition)
       xu0 = 0;
       if length(zohsim),
           % ZOH discretization
           if ComputeX,
               % Make sure to match FOH state dimension
               [az,bz,cz,dz] = ssdata(c2d(sys,dt));
               bz = bz(:,zohsim);   dz = dz(:,zohsim);
           else
               systmp = sminreal(subsref(sys,substruct('()',{':' zohsim})));
               [az,bz,cz,dz] = ssdata(c2d(systmp,dt));
           end
           % Simulate
           [yu0,xu0] = simresp(az,bz,cz,dz,id(zohsim),od,u0(ones(1,lt),:),0);
           y = y + yu0;
       end
       
       % Derive trajectory of original CT state
       % Note: ComputeX=1 implies ioDelay=0
       if ComputeX,
           for j=1:nu,
               u(:,j) = [zeros(min(id(j),lt),1) ; u(1:lt-id(j),j)];
           end
           x = z - u * gic(:,nx+1:nx+nu).' + xu0;
           x = x(:,1:nx); 
       end   
       
   else
       % FOH discretization with I/O delays
       % RE: Implies x0=0 and ComputeX=0
       sysfoh = c2d(sys,dt,'foh');
       
       % Extract SS data and discrete delays 
       [af,bf,cf,df] = ssdata(sysfoh);
       Ddelays = get(sysfoh.lti,{'inputdelay','outputdelay','iodelay'});
       [id,od,iod] = deal(Ddelays{:});
       ziod = all(~iod,1);  % input channels w/o any discrete I/O delays
       
       % Zero out u(1,:) and use separate ZOH simulation for contribution 
       % of nonzero u(1,j)
       zohsim = find(u(1,:));
       if length(zohsim),
           % Save first input value
           u0 = u(1,zohsim);
           u(:,zohsim) = u(:,zohsim) - u0(ones(1,lt),:);
       end
       
       % FOH simulation of channels without discrete I/O delays (iod(:,j) = 0).
       y = simresp(af,bf(:,ziod),cf,df(:,ziod),id(ziod),od,u(:,ziod),0);
       
       % FOH simulation of channels with discrete I/O delays
       for j=find(~ziod),
           tdj = id(j) + od + iod(:,j); % total discrete delay
           % Squeeze subsystem order and simulate
           [afj,bfj,cfj] = smreal(af,bf(:,j),cf,[]);
           y = y + simresp(afj,bfj,cfj,df(:,j),0,tdj,u(:,j),0);
       end
        
       % Superpose ZOH simulation of response to steps of amplitude u(1,ZOHSIM) 
       if length(zohsim),
           % ZOH discretization
           systmp = sminreal(subsref(sys,substruct('()',{':' zohsim})));
           [az,bz,cz,dz] = ssdata(c2d(systmp,dt));
           idz = id(zohsim);
           % Input channels without I/O delays
           sel = find(ziod(zohsim));
           y = y + simresp(az,bz(:,sel),cz,dz(:,sel),idz(sel),od,u0(ones(1,lt),sel),0);
           % Input channels with I/O delays
           for j=find(~ziod(zohsim)),
               jchan = zohsim(j);
               tdj = id(jchan) + od + iod(:,jchan); % total discrete delay
               [azj,bzj,czj] = smreal(az,bz(:,j),cz,[]);
               y = y + simresp(azj,bzj,czj,dz(:,j),0,tdj,u0(ones(1,lt),jchan),0);
           end
       end
   end
       
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [y,x] = simresp(a,b,c,d,id,od,u,x0)
%SIMRESP  Simulation with discrete-time response

lt = size(u,1);  % number of samples
if ~any(x0),
   x0 = zeros(size(a,1),1);
end

% Delay j-th input by j-th input delay ID(j)
for j=find(id(:))',
   u(:,j) = [zeros(min(id(j),lt),1) ; u(1:lt-id(j),j)];
end

% Simulate response with LTITR
x = ltitr(a,b,u,x0);
y = x * c.' + u * d.';

% Delay i-th output by i-th output delay OD(i)
for i=find(od(:))',
   y(:,i) = [zeros(min(od(i),lt),1) ; y(1:lt-od(i),i)];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function u = interp0(t0,u0,t)
%INTERP0   ZOH interpolation of the inout data between samples.

dt = t(2)-t(1); % new sampling period

% Augment input data by adding values u0(i-1,:) at time t0(i)-dt/2 
t0 = [t0 ; t0(2:end)-dt/2];
u0 = [u0 ; u0(1:end-1,:)];

% Sort resulting time vector
[t0,iperm] = sort(t0);
u0 = u0(iperm,:);
   
% Interpolate extended input data linearly
u = interp1(t0,u0,t);


