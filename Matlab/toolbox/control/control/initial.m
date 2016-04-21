function [yout,x,t] = initial(a,b,c,d,x0,t)
%INITIAL  Initial condition response of state-space models.
%
%   INITIAL(SYS,X0) plots the undriven response of the state-space 
%   model SYS (created with SS) with initial condition X0 on the 
%   states.  This response is characterized by the equations
%                        .
%     Continuous time:   x = A x ,  y = C x ,  x(0) = x0 
%
%     Discrete time:  x[k+1] = A x[k],  y[k] = C x[k],  x[0] = x0 .
%
%   The time range and number of points are chosen automatically.  
%
%   INITIAL(SYS,X0,TFINAL) simulates the time response from t=0 
%   to the final time t=TFINAL.  For discrete-time models with 
%   unspecified sample time, TFINAL should be the number of samples.
%
%   INITIAL(SYS,X0,T) specifies a time vector T to be used for 
%   simulation.  For discrete systems, T should be of the form  
%   0:Ts:Tf where Ts is the sample time.  For continuous-time models,
%   T should be of the form 0:dt:Tf where dt will become the sample
%   time of a discrete approximation of the continuous model.
%
%   INITIAL(SYS1,SYS2,...,X0,T) plots the response of multiple LTI 
%   models SYS1,SYS2,... on a single plot.  The time vector T is 
%   optional.  You can also specify a color, line style, and marker 
%   for each system, as in  
%      initial(sys1,'r',sys2,'y--',sys3,'gx',x0).
%
%   When invoked with left hand arguments,
%      [Y,T,X] = INITIAL(SYS,X0)
%   returns the output response Y, the time vector T used for simulation, 
%   and the state trajectories X.  No plot is drawn on the screen.  The
%   matrix Y has LENGTH(T) rows and as many columns as outputs in SYS.
%   Similarly, X has LENGTH(T) rows and as many columns as states.
%	
%   See also IMPULSE, STEP, LSIM, LTIVIEW, LTIMODELS.

% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%INITIAL Initial condition response of continuous-time linear systems.
%   INITIAL(A,B,C,D,X0) plots the time response of the linear system
%       .
%       x = Ax + Bu
%       y = Cx + Du
%
%   due to an initial condition on the states.  The time vector is 
%   automatically determined based on the system poles and zeros.  
%
%   INITIAL(A,B,C,D,X0,T) plots the initial condition response for the
%   times specified in the vector T.  The time vector must be 
%   regularly spaced.  When invoked with left hand arguments:
%   
%       [Y,X,T] = INITIAL(A,B,C,D,X0,...)
%
%   returns the output and state responses (Y and X), and the time 
%   vector (T).  No plot is drawn on the screen.  The matrix Y has as
%   many columns as outputs and one row for element in T.  Similarly,
%   the matrix X has as many columns as states and length(T) rows.
%   
%   See also: IMPULSE,STEP,LSIM, and DINITIAL.

%	Clay M. Thompson  7-6-90
%	Revised ACWG 6-21-92
%	Revised AFP 9-21-94,  PG 4-25-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.15 $  $Date: 2002/04/10 06:24:05 $

ni = nargin;
no = nargout;
error(nargchk(5,6,ni));

% Determine which syntax is being used
error(abcdchk(a,b,c,d))
sys = ss(a,b,c,d);
if ni==5,
   t = [];
end

if no,
   [yout,t,x] = initial(sys,x0,t);
   t = t';
else
   initial(sys,x0,t);
end

% end initial
