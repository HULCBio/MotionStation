function [reout,im,w] = dnyquist(a,b,c,d,Ts,iu,w)
%DNYQUIST Nyquist frequency response for discrete-time linear systems.
%   DNYQUIST(A,B,C,D,Ts,IU) produces a Nyquist plot from the inputs
%   input IU to all the outputs of the system:
%                                                       -1
%         x[n+1] = Ax[n] + Bu[n]    G(w) = C(exp(jwT)I-A) B + D  
%         y[n]   = Cx[n] + Du[n]    RE(w) = real(G(w)), IM(w) = imag(G(w))
%
%   The frequency range and number of points are chosen automatically.
%
%   DNYQUIST(NUM,DEN,Ts) produces the Nyquist plot for the polynomial
%   transfer function G(z) = NUM(z)/DEN(z) where NUM and DEN contain
%   the polynomial coefficients in descending powers of z. 
%
%   DNYQUIST(A,B,C,D,Ts,IU,W) or DNYQUIST(NUM,DEN,Ts,W) uses the user-
%   supplied freq. vector W which must contain the frequencies, in 
%   rad/s, at which the Nyquist response is to be evaluated.  
%   Aliasing will occur at frequencies greater than the Nyquist 
%   frequency (pi/Ts). With left hand arguments,
%       [RE,IM,W] = DNYQUIST(A,B,C,D,Ts,...)
%       [RE,IM,W] = DNYQUIST(NUM,DEN,Ts,...) 
%   returns the frequency vector W and matrices RE and IM with as many
%       columns as outputs and length(W) rows.  No plot is drawn on the 
%   screen.
%
%   See also: LOGSPACE,MARGIN,DBODE, and DNICHOLS.

%   J.N. Little 10-11-85
%   Revised A.C.W.Grace 8-15-89, 2-12-91, 6-21-92
%   Revised Clay M. Thompson 7-9-90, AFP 10-1-94, PG 6-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 06:33:53 $

ni = nargin;
no = nargout;
if ni==0,
   eval('dexresp(''dnyquist'')')
   return
end
error(nargchk(3,7,ni));

% Determine which syntax is being used
switch ni
case 3
   if size(a,1)>1,
      % SIMO syntax
      a = num2cell(a,2);
      den = b;
      b = cell(size(a,1),1);
      b(:) = {den};
   end
   sys = tf(a,b,c);
   w = [];

case 4
   % Transfer function form with time vector
   if size(a,1)>1,
      % SIMO syntax
      a = num2cell(a,2);
      den = b;
      b = cell(size(a,1),1);
      b(:) = {den};
   end
   sys = tf(a,b,c);
   w = d;

case 5
   % State space system without iu or time vector
   sys = ss(a,b,c,d,Ts);
   w = [];

otherwise
   % State space system, with iu but w/o time vector
   if min(size(iu))>1,
      error('IU must be a vector.');
   elseif isempty(iu),
      iu = 1:size(d,2);
   end
   sys = ss(a,b(:,iu),c,d(:,iu),Ts);
   if ni<7,
      w = [];
   end
end

if no==0,
   nyquist(sys,w);
else
   [reout,im,w] = nyquist(sys,w);
   [Ny,Nu,lw] = size(reout);
   reout = reshape(reout,[Ny*Nu lw]).';
   im = reshape(im,[Ny*Nu lw]).';
end

% end dnyquist
