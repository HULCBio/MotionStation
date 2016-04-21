function  [yout,x] = dlsim(a, b, c, d, u, x0)
%DLSIM  Simulation of discrete-time linear systems.
%   DLSIM(A,B,C,D,U)  plots the time response of the discrete system:
%
%       x[n+1] = Ax[n] + Bu[n]
%       y[n]   = Cx[n] + Du[n]
%
%   to input sequence U.  Matrix U must have as many columns as there
%   are inputs, u.  Each row of U corresponds to a new time point.
%   DLSIM(A,B,C,D,U,X0) can be used if initial conditions exist.
%
%   DLSIM(NUM,DEN,U) plots the time response of the transfer function
%   description  G(z) = NUM(z)/DEN(z)  where NUM and DEN contain the 
%   polynomial coefficients in descending powers of z.  If 
%   LENGTH(NUM)=LENGTH(DEN) then DLSIM(NUM,DEN,U) is equivalent to 
%   FILTER(NUM,DEN,U).  When invoked with left hand arguments,
%       [Y,X] = DLSIM(A,B,C,D,U)
%       [Y,X] = DLSIM(NUM,DEN,U)
%   returns the output and state time history in the matrices Y and X.
%   No plot is drawn on the screen.  Y has as many columns as there 
%   are outputs and LENGTH(U) rows.  X has as many columns as there 
%   are states and LENGTH(U) rows. 
%
%   See also:  LSIM, STEP, IMPULSE, INITIAL.

%   J.N. Little 4-21-85
%   Revised 7-18-88 JNL
%   Revised 7-31-90  Clay M. Thompson
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 06:34:05 $

%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
ni = nargin;
no = nargout;
error(nargchk(3,6,ni));
Ts = -1;
t = [];

switch ni
case 3
   % Transfer function description (unknown sampling)
   if size(a,1)>1,
      % SIMO syntax
      a = num2cell(a,2);
      den = b;
      b = cell(size(a,1),1);
      b(:) = {den};
   end
   sys = tf(a,b,Ts);
   u = c;
   x0 = [];
case 4
   error('Wrong number of input arguments.');
case 5
   sys = ss(a,b,c,d,Ts);
   x0 = zeros(size(a,1),1);
case 6
   sys = ss(a,b,c,d,Ts);
end

if no,
   [yout,t1,x] = lsim(sys,u,[],x0);
else
   lsim(sys,u,t,x0)
end

% end dlsim
