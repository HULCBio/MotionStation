function  [yout,x] = lsim(a, b, c, d, u, t, x0)
%LSIM  Simulate time response of LTI models to arbitrary inputs.
%
%   LSIM(SYS,U,T) plots the time response of the LTI model SYS to the
%   input signal described by U and T.  The time vector T consists of 
%   regularly spaced time samples and U is a matrix with as many columns 
%   as inputs and whose i-th row specifies the input value at time T(i).
%   For example, 
%           t = 0:0.01:5;   u = sin(t);   lsim(sys,u,t)  
%   simulates the response of a single-input model SYS to the input 
%   u(t)=sin(t) during 5 seconds.
%
%   For discrete-time models, U should be sampled at the same rate as SYS
%   (T is then redundant and can be omitted or set to the empty matrix).
%   For continuous-time models, choose the sampling period T(2)-T(1) small 
%   enough to accurately describe the input U.  LSIM issues a warning when
%   U is undersampled and hidden oscillations may occur.
%         
%   LSIM(SYS,U,T,X0) specifies the initial state vector X0 at time T(1) 
%   (for state-space models only).  X0 is set to zero when omitted.
%
%   LSIM(SYS1,SYS2,...,U,T,X0) simulates the response of multiple LTI
%   models SYS1,SYS2,... on a single plot.  The initial condition X0 
%   is optional.  You can also specify a color, line style, and marker 
%   for each system, as in  
%      lsim(sys1,'r',sys2,'y--',sys3,'gx',u,t).
%
%   Y = LSIM(SYS,U,T) returns the output history Y.  No plot is drawn on 
%   the screen.  The matrix Y has LENGTH(T) rows and as many columns as 
%   outputs in SYS.  For state-space models, 
%      [Y,T,X] = LSIM(SYS,U,T,X0) 
%   also returns the state trajectory X, a matrix with LENGTH(T) rows
%   and as many columns as states.
%
%   For continuous-time models,
%      LSIM(SYS,U,T,X0,'zoh')  or  LSIM(SYS,U,T,X0,'foh') 
%   explicitly specifies how the input values should be interpolated 
%   between samples (zero-order hold or linear interpolation).  By 
%   default, LSIM selects the interpolation method automatically based 
%   on the smoothness of the signal U.
%
%   See also GENSIG, STEP, IMPULSE, INITIAL, LTIMODELS.
% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%LSIM	Simulation of continuous-time linear systems to arbitrary inputs.
%	LSIM(A,B,C,D,U,T) plots the time response of the linear system:
%			.
%			x = Ax + Bu
%			y = Cx + Du
%	to the input time history U. Matrix U must have as many columns as
%	there are inputs, U.  Each row of U corresponds to a new time 
%	point, and U must have LENGTH(T) rows.  The time vector T must be
%	regularly spaced.  LSIM(A,B,C,D,U,T,X0) can be used if initial 
%	conditions exist.
%
%	LSIM(NUM,DEN,U,T) plots the time response of the polynomial 
%	transfer function  G(s) = NUM(s)/DEN(s)  where NUM and DEN contain
%	the polynomial coefficients in descending powers of s.  When 
%	invoked with left hand arguments,
%		[Y,X] = LSIM(A,B,C,D,U,T)
%		[Y,X] = LSIM(NUM,DEN,U,T)
%	returns the output and state time history in the matrices Y and X.
%	No plot is drawn on the screen.  Y has as many columns as there 
%	are outputs, y, and with LENGTH(T) rows.  X has as many columns 
%	as there are states.
%
%	See also: STEP,IMPULSE,INITIAL and DLSIM.

%	LSIM normally linearly interpolates the input (using a first order hold)
%	which is more accurate for continuous inputs. For discrete inputs such 
%	as square waves LSIM tries to detect these and uses a more accurate 
%	zero-order hold method. LSIM can be confused and for accurate results
%	a small time interval should be used.

%	J.N. Little 4-21-85
%	Revised 7-31-90  Clay M. Thompson
%       Revised A.C.W.Grace 8-27-89 (added first order hold)
%	                    1-21-91 (test to see whether to use foh or zoh)
%	Revised 12-5-95 Andy Potvin
%	Revised 5-8-96  P. Gahinet
%	Copyright 1986-2003 The MathWorks, Inc.
%	$Revision: 1.19.4.3 $  $Date: 2004/04/10 23:13:38 $

ni = nargin;
no = nargout;
error(nargchk(4,7,ni));

switch ni
case 4
   % Transfer function description 
   if size(a,1)>1,
      % SIMO syntax
      a = num2cell(a,2);
      den = b;
      b = cell(size(a,1),1);
      b(:) = {den};
   end
   sys = tf(a,b);
   u = c;
   t = d;
   x0 = [];
case 5
   error('Wrong number of input arguments.');
case 6
   sys = ss(a,b,c,d);
   x0 = zeros(size(a,1),1);
case 7
   sys = ss(a,b,c,d);
end

if no,
   [yout,t1,x] = lsim(sys,u,t,x0);
else
   lsim(sys,u,t,x0)
end

% end lsim
