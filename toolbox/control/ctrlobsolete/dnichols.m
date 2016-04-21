function [magout,phase,w] = dnichols(a,b,c,d,Ts,iu,w)
%DNICHOLS Nichols frequency response for discrete-time linear systems.
%
%       DNICHOLS(A,B,C,D,Ts,IU) produces a Nichols plot from the single 
%       input IU to all the outputs of the discrete state-space system 
%       (A,B,C,D).  IU is an index into the inputs of the system and 
%       specifies which input to use for the Nichols response.  Ts is the
%       sample period.  The frequency range and number of points are 
%       chosen automatically.
%
%       DNICHOLS(NUM,DEN,Ts) produces the Nichols plot for the polynomial 
%       transfer function G(z) = NUM(z)/DEN(z) where NUM and DEN contain
%       the polynomial coefficients in descending powers of z. 
%
%       DNICHOLS(A,B,C,D,Ts,IU,W) or DNICHOLS(NUM,DEN,Ts,W) uses the user-
%       supplied freq. vector W which must contain the frequencies, in 
%       rad/s, at which the Nichols response is to be evaluated.  
%       Aliasing will occur at frequencies greater than the Nyquist 
%       frequency (pi/Ts). With left hand arguments,
%               [MAG,PHASE,W] = DNICHOLS(A,B,C,D,Ts,...)
%               [MAG,PHASE,W] = DNICHOLS(NUM,DEN,Ts,...) 
%       returns the frequency vector W and matrices MAG and PHASE (in 
%       degrees) with as many columns as outputs and length(W) rows.  No
%       plot is drawn on the screen.  Draw the Nichols grid with NGRID.
%
%       See also  LOGSPACE, SEMILOGX, MARGIN, DBODE, and DNYQUIST.

%       Clay M. Thompson 7-10-90
%       Revised ACWG 2-12-91, 6-21-92
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.11 $  $Date: 2002/04/10 06:33:56 $

ni = nargin;
no = nargout;
if ni==0,
   eval('dexresp(''dnichols'')')
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
   nichols(sys,w);
else
   [magout,phase,w] = nichols(sys,w);
   [Ny,Nu,lw] = size(magout);
   magout = reshape(magout,[Ny*Nu lw]).';
   phase = reshape(phase,[Ny*Nu lw]).';
end

% end dnichols
