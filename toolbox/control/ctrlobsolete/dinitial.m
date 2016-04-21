function [yout,x,n] = dinitial(a,b,c,d,x0,n)
%DINITIAL Initial condition response of discrete-time linear systems.
%   DINITIAL(A,B,C,D,X0) plots the time response of the discrete
%   system:
%       x[n+1] = Ax[n] + Bu[n]
%       y[n]   = Cx[n] + Du[n]
%
%   due to an initial condition on the states.  The number of sample
%   points is automatically determined based on the system poles and
%   zeros.  
%
%   DINITIAL(A,B,C,D,X0,N) uses the user-supplied number of points, N.
%   When invoked with left hand arguments:
%
%       [Y,X,N] = DINITIAL(A,B,C,D,X0,...)
%
%   returns the output and state responses (Y and X), and the number
%       of points (N).  No plot is drawn on the screen.  The matrix Y has as 
%   many columns as outputs and X has as many columns as there are states.
%   
%   See also: DIMPULSE,DSTEP,DLSIM, and INITIAL.

%	Clay M. Thompson  7-6-90
%	Revised ACWG 6-21-92
%	Revised AFP 9-21-94,  PG 4-25-96
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.10 $  $Date: 2002/04/10 06:34:17 $

%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])

ni = nargin;
no = nargout;
if ni==0,
   eval('exresp(''dinitial'',1)')
   return
end
error(nargchk(5,6,ni));
Ts = -1;

% Determine which syntax is being used
error(abcdchk(a,b,c,d))
sys = ss(a,b,c,d,Ts);
if ni==5,
   n = [];
end

if no,
   [yout,t,x] = initial(sys,x0,n);
   n = length(t);
else
   initial(sys,x0,n);
end

% end initial
