function [magout,phase,w] = bode(a,b,c,d,iu,w)
%BODE  Bode frequency response of LTI models.
%
%   BODE(SYS) draws the Bode plot of the LTI model SYS (created with
%   either TF, ZPK, SS, or FRD).  The frequency range and number of  
%   points are chosen automatically.
%
%   BODE(SYS,{WMIN,WMAX}) draws the Bode plot for frequencies
%   between WMIN and WMAX (in radians/second).
%
%   BODE(SYS,W) uses the user-supplied vector W of frequencies, in
%   radian/second, at which the Bode response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   BODE(SYS1,SYS2,...,W) graphs the Bode response of multiple LTI
%   models SYS1,SYS2,... on a single plot.  The frequency vector W
%   is optional.  You can specify a color, line style, and marker 
%   for each model, as in  
%      bode(sys1,'r',sys2,'y--',sys3,'gx').
%
%   [MAG,PHASE] = BODE(SYS,W) and [MAG,PHASE,W] = BODE(SYS) return the
%   response magnitudes and phases in degrees (along with the frequency 
%   vector W if unspecified).  No plot is drawn on the screen.  
%   If SYS has NY outputs and NU inputs, MAG and PHASE are arrays of 
%   size [NY NU LENGTH(W)] where MAG(:,:,k) and PHASE(:,:,k) determine 
%   the response at the frequency W(k).  To get the magnitudes in dB, 
%   type MAGDB = 20*log10(MAG).
%
%   For discrete-time models with sample time Ts, BODE uses the
%   transformation Z = exp(j*W*Ts) to map the unit circle to the 
%   real frequency axis.  The frequency response is only plotted 
%   for frequencies smaller than the Nyquist frequency pi/Ts, and 
%   the default value 1 (second) is assumed when Ts is unspecified.
%
%   See also BODEMAG, NICHOLS, NYQUIST, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.

% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%BODE   Bode frequency response for continuous-time linear systems.
%   BODE(A,B,C,D,IU) produces a Bode plot from the single input IU to
%   all the outputs of the continuous state-space system (A,B,C,D).
%   IU is an index into the inputs of the system and specifies which
%   input to use for the Bode response.  The frequency range and
%   number of points are chosen automatically.
%
%   BODE(NUM,DEN) produces the Bode plot for the polynomial transfer
%   function G(s) = NUM(s)/DEN(s) where NUM and DEN contain the 
%   polynomial coefficients in descending powers of s. 
%
%   BODE(A,B,C,D,IU,W) or BODE(NUM,DEN,W) uses the user-supplied 
%   frequency vector W which must contain the frequencies, in 
%   radians/sec, at which the Bode response is to be evaluated.  See 
%   LOGSPACE to generate logarithmically spaced frequency vectors. 
%   When invoked with left hand arguments,
%       [MAG,PHASE,W] = BODE(A,B,C,D,...)
%       [MAG,PHASE,W] = BODE(NUM,DEN,...) 
%   returns the frequency vector W and matrices MAG and PHASE (in 
%   degrees) with as many columns as outputs and length(W) rows.  No
%   plot is drawn on the screen. 
%
%   See also LOGSPACE, SEMILOGX, MARGIN, NICHOLS, and NYQUIST.

%   J.N. Little 10-11-85
%   Revised A.C.W.Grace 8-15-89, 2-4-91, 6-21-92
%   Revised Clay M. Thompson 7-9-90
%   Revised A.Potvin 10-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.23 $  $Date: 2002/04/10 06:22:45 $

ni = nargin;
no = nargout;
% Check for demo and quick exit
if ni==0,
   eval('exresp(''bode'')')
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
   w = [];

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
   w = c;

case 4
   % State space system without iu or time vector
   sys = ss(a,b,c,d);
   w = [];

otherwise
   % State space system, with iu but w/o time vector
   if min(size(iu))>1,
      error('IU must be a vector.');
   elseif isempty(iu),
      iu = 1:size(d,2);
   end
   sys = ss(a,b(:,iu),c,d(:,iu));
   if ni<6,
      w = [];
   end
end

if no==0,
   bode(sys,w)
else
   [magout,phase,w] = bode(sys,w);
   [Ny,Nu,lw] = size(magout);
   magout = reshape(magout,[Ny*Nu lw]).';
   phase = reshape(phase,[Ny*Nu lw]).';
end

% end bode
