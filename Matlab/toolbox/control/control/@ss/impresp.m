function [y,t,x] = impresp(sys,Ts,t,t0)
%IMPRESP  Impulse response of a single LTI model
%
%   [Y,T,X] = IMPRESP(SYS,TS,T,T0) computes the impulse response
%   of the LTI model SYS with sample time TS at the time stamps
%   T (starting at t=0).  The response from t=0 to t=T0 is 
%   discarded if T0>0.
%
%   LOW-LEVEL UTILITY, CALLED BY IMPULSE.

%	 Author: P. Gahinet, 4-98
%	 Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.13 $  $Date: 2002/04/10 06:01:39 $

ComputeX = (nargout>2);
lt = length(t);
dt = t(2)-t(1);
nx = size(sys.a{1},1);  % true number of states

% Discretize system if continuous (using impulse-invariant method)
if Ts==0,
	sys = c2d(sys,dt,'imp');
end

% Extract data
[a,b,c,d] = ssdata(sys);
[ny,nu] = size(d);

% Pre-allocate outputs
y = zeros(lt,ny,nu);
if ComputeX, 
   x = zeros(lt,nx,nu);  
end

% Extract discrete-time delays and reduce to a pair
% (TDIN,TDOUT) of input and output delays to be used
% in the simulation of each input channel
if ComputeX | ny==0
   % State trajectory required -> no I/O delays
   Tdin = get(sys.lti,'inputdelay')';
   Tdout = repmat(get(sys.lti,'outputdelay'),[1 nu]);
else
   % Get cumulative I/O delays
   Tdio = totaldelay(sys);
   Tdin = min(Tdio,[],1);              % input delays for each input channel
   Tdout = Tdio - Tdin(ones(1,ny),:);  % output delays for each input channel
end


% Simulate response of each input channel to u = [1 0 0 0...]
u = zeros(lt,1);
u(1) = 1;
x0 = zeros(size(a,1),1);
for j=find(Tdin<lt),
   [y(:,:,j),xj] = impsim(a,b(:,j),c,d(:,j),u,x0,Tdin(j),Tdout(:,j));
   if ComputeX & nx>0,
      % Note: Delays consist of input + output delays when ComputeX=1
      x(:,:,j) = xj(:,1:nx);  
   end
end
	
% Clip response if T0>0
if t0>0,  
	keep = find(t>=t0);
	y = y(keep,:,:);   
	t = t(keep);  
	if ComputeX,
		x = x(keep,:,:);
	end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [y,x] = impsim(a,b,c,d,u,x0,Tdin,Tdout)
%IMPSIM  Simulate impulse response of single-input model

lt = length(u);
ny = size(c,1);
y = zeros(lt,ny);

% Simulate with LTITR
x = ltitr(a,b,u(1:lt-Tdin),x0);

% Compute output trajectory
ctr = c.';
Tdio = Tdout + Tdin;  % I/O delays 

if any(diff(Tdio)) | ny==0
	for i=1:ny,
		y(Tdio(i)+1:lt,i) = x(1:lt-Tdio(i),:) * ctr(:,i);
		% Add impulse at t=0 (discrete-time case)
		y(Tdio(i)+1,i) = y(Tdio(i)+1,i) + d(i);
	end
else
	y(Tdio(1)+1:lt,:) = x(1:lt-Tdio(1),:) * ctr;
	y(Tdio(1)+1,:) = y(Tdio(1)+1,:) + d.';
end

% Set X output
x = [zeros(Tdin,size(x,2)) ; x];


