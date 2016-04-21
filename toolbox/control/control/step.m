function [yout,x,t] = step(a,b,c,d,iu,t)
%STEP  Step response of LTI models.
%
%   STEP(SYS) plots the step response of the LTI model SYS (created 
%   with either TF, ZPK, or SS).  For multi-input models, independent
%   step commands are applied to each input channel.  The time range 
%   and number of points are chosen automatically.
%
%   STEP(SYS,TFINAL) simulates the step response from t=0 to the 
%   final time t=TFINAL.  For discrete-time models with unspecified 
%   sampling time, TFINAL is interpreted as the number of samples.
%
%   STEP(SYS,T) uses the user-supplied time vector T for simulation. 
%   For discrete-time models, T should be of the form  Ti:Ts:Tf 
%   where Ts is the sample time.  For continuous-time models,
%   T should be of the form  Ti:dt:Tf  where dt will become the sample 
%   time for the discrete approximation to the continuous system.  The
%   step input is always assumed to start at t=0 (regardless of Ti).
%
%   STEP(SYS1,SYS2,...,T) plots the step response of multiple LTI
%   models SYS1,SYS2,... on a single plot.  The time vector T is 
%   optional.  You can also specify a color, line style, and marker 
%   for each system, as in 
%      step(sys1,'r',sys2,'y--',sys3,'gx').
%
%   [Y,T] = STEP(SYS) returns the output response Y and the time 
%   vector T used for simulation.  No plot is drawn on the screen.  
%   If SYS has NY outputs and NU inputs, and LT = length(T), Y is an 
%   array of size [LT NY NU] where Y(:,:,j) gives the step response 
%   of the j-th input channel.
%
%   [Y,T,X] = STEP(SYS) also returns, for a state-space model SYS, the
%   state trajectory X, a LT-by-NX-by-NU array if SYS has NX states.
%
%   See also IMPULSE, INITIAL, LSIM, LTIVIEW, LTIMODELS.

%       Extra notes on user-supplied T:  For continuous-time systems, the system is 
%       converted to discrete time with a sample time of dt=t(2)-t(1).  The time 
%       vector plotted is then t=t(1):dt:t(end).  

% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%STEP   Step response of continuous-time linear systems.
%	STEP(A,B,C,D,IU)  plots the time response of the linear system:
%		.
%		x = Ax + Bu
%		y = Cx + Du
%	to a step applied to the input IU.  The time vector is auto-
%	matically determined.  STEP(A,B,C,D,IU,T) allows the specification
%	of a regularly spaced time vector T.
%
%	[Y,X] = STEP(A,B,C,D,IU,T) or [Y,X,T] = STEP(A,B,C,D,IU) returns
%	the output and state time response in the matrices Y and X 
%	respectively.  No plot is drawn on the screen.  The matrix Y has 
%	as many columns as there are outputs, and LENGTH(T) rows.  The 
%	matrix X has as many columns as there are states.  If the time 
%	vector is not specified, then the automatically determined time 
%	vector is returned in T.
%
%	[Y,X] = STEP(NUM,DEN,T) or [Y,X,T] = STEP(NUM,DEN) calculates the 
%	step response from the transfer function description 
%	G(s) = NUM(s)/DEN(s) where NUM and DEN contain the polynomial 
%	coefficients in descending powers of s.
%
%	See also: INITIAL, IMPULSE, LSIM and DSTEP.

%	J.N. Little 4-21-85
%	Revised A.C.W.Grace 9-7-89, 5-21-92
%	Revised A. Potvin 12-1-95
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.21 $  $Date: 2002/04/10 06:25:50 $

ni = nargin;
no = nargout;
if ni==0,
   eval('exresp(''step'')')
   return
end
error(nargchk(2,6,ni));

% Determine which syntax is being used
switch ni
case 2
   if size(a,1)>1,
      % SIMO syntax
      a = num2cell(a,2);
      den = b;
      b = cell(size(a,1),1);
      b(:) = {den};
   end
   sys = tf(a,b);
   t = [];

case 3
   % Transfer function form with time vector
   if size(a,1)>1,
      % SIMO syntax
      a = num2cell(a,2);
      den = b;
      b = cell(size(a,1),1);
      b(:) = {den};
   end
   sys = tf(a,b);
   t = c;

case 4
   % State space system without iu or time vector
   sys = ss(a,b,c,d);
   t = [];

otherwise
   % State space system with iu 
   if min(size(iu))>1,
      error('IU must be a vector.');
   elseif isempty(iu),
      iu = 1:size(d,2);
   end
   sys = ss(a,b(:,iu),c,d(:,iu));
   if ni<6, 
      t = [];
   end
end

if no==1,
   yout = step(sys,t);
   yout = yout(:,:);
elseif no>1,
   [yout,t,x] = step(sys,t);
   yout = yout(:,:);
   x = x(:,:);
   t = t';
else
   step(sys,t);
end

% end step
