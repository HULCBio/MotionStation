function [yout,x,n] = dimpulse(a,b,c,d,iu,n)
%DIMPULSE Impulse response of discrete-time linear systems.
%    DIMPULSE(A,B,C,D,IU)  plots the response of the discrete system:
%
%       x[n+1] = Ax[n] + Bu[n]
%       y[n]   = Cx[n] + Du[n]
%
%   to an unit sample applied to the inputs IU.  The number of
%   points is determined automatically.
%
%   DIMPULSE(NUM,DEN) plots the impulse response of the polynomial
%   transfer function  G(z) = NUM(z)/DEN(z)  where NUM and DEN contain
%   the polynomial coefficients in descending powers of z.
%
%   DIMPULSE(A,B,C,D,IU,N) or DIMPULSE(NUM,DEN,N) uses the user-
%   supplied number of points, N.  When invoked with left hand 
%   arguments,
%       [Y,X] = DIMPULSE(A,B,C,D,...)
%       [Y,X] = DIMPULSE(NUM,DEN,...)
%   returns the output and state time history in the matrices Y and X.
%   No plot is drawn on the screen.  Y has as many columns as there 
%   are outputs and X has as many columns as there are states.
%
%   See also  IMPULSE, STEP, INITIAL, LSIM.

%   J.N. Little 4-21-85
%   Revised CMT 7-31-90, ACWG 5-30-91, AFP 10-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/10 06:34:20 $

%warning(['This calling syntax for ' mfilename ...
%       ' will not be supported in the future: use IMPULSE(SYS,...) instead.'])

ni = nargin;
no = nargout;
if ni==0, 
   eval('exresp(''dimpulse'')')
   return
end
error(nargchk(2,6,ni))
Ts = -1;

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
   sys = tf(a,b,Ts);
   n = [];

case 3
   % Transfer function form with time vector
   if size(a,1)>1,
      % SIMO syntax
      a = num2cell(a,2);
      den = b;
      b = cell(size(a,1),1);
      b(:) = {den};
   end
   sys = tf(a,b,Ts);
   n = c;

case 4
   % State space system without iu or time vector
   sys = ss(a,b,c,d,Ts);
   n = [];

otherwise
   % State space system, with iu but w/o time vector
   if min(size(iu))>1,
      error('IU must be a vector.');
   elseif isempty(iu),
      iu = 1:size(d,2);
   end
   sys = ss(a,b(:,iu),c,d(:,iu),Ts);
   if ni<6, 
      n = [];
   end
end


if no==1,
   yout = impulse(sys,n);
   yout = yout(:,:);
elseif no>1,
   [yout,t,x] = impulse(sys,n);
   yout = yout(:,:);
   x = x(:,:);
   n = length(t);
else
   impulse(sys,n)
end

% end dimpulse
