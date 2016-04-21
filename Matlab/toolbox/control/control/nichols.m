function [magout,phase,w] = nichols(a,b,c,d,iu,w)
%NICHOLS  Nichols frequency response of LTI models.
%
%   NICHOLS(SYS) draws the Nichols plot of the LTI model SYS
%   (created with either TF, ZPK, SS, or FRD).  The frequency range  
%   and number of points are chosen automatically.  See BODE for  
%   details on the notion of frequency in discrete-time.
%
%   NICHOLS(SYS,{WMIN,WMAX}) draws the Nichols plot for frequencies
%   between WMIN and WMAX (in radian/second).
%
%   NICHOLS(SYS,W) uses the user-supplied vector W of frequencies, in
%   radians/second, at which the Nichols response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   NICHOLS(SYS1,SYS2,...,W) plots the Nichols plot of multiple LTI
%   models SYS1,SYS2,... on a single plot.  The frequency vector W
%   is optional.  You can also specify a color, line style, and marker 
%   for each system, as in  
%      nichols(sys1,'r',sys2,'y--',sys3,'gx').
%
%   [MAG,PHASE] = NICHOLS(SYS,W) and [MAG,PHASE,W] = NICHOLS(SYS) return
%   the response magnitudes and phases in degrees (along with the 
%   frequency vector W if unspecified).  No plot is drawn on the screen.  
%   If SYS has NY outputs and NU inputs, MAG and PHASE are arrays of 
%   size [NY NU LENGTH(W)] where MAG(:,:,k) and PHASE(:,:,k) determine 
%   the response at the frequency W(k).
%
%   See also BODE, NYQUIST, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.

% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%NICHOLS Nichols frequency response for continuous-time linear systems.
%       NICHOLS(A,B,C,D,IU) produces a Nichols plot from the single
%       input IU to all the outputs of the continuous state-space system 
%       (A,B,C,D).  IU is an index into the inputs of the system and 
%       specifies which input to use for the Nichols response.  The 
%       frequency range and number of points are chosen automatically.
%
%       NICHOLS(NUM,DEN) produces the Nichols plot for the polynomial 
%       transfer function G(s) = NUM(s)/DEN(s) where NUM and DEN contain
%       the polynomial coefficients in descending powers of s. 
%
%       NICHOLS(A,B,C,D,IU,W) or NICHOLS(NUM,DEN,W) uses the user-supplied
%       freq. vector W which must contain the frequencies, in radians/sec,
%       at which the Nichols response is to be evaluated.  When invoked 
%       with left hand arguments,
%               [MAG,PHASE,W] = NICHOLS(A,B,C,D,...)
%               [MAG,PHASE,W] = NICHOLS(NUM,DEN,...) 
%       returns the frequency vector W and matrices MAG and PHASE (in 
%       degrees) with as many columns as outputs and length(W) rows.  No 
%       plot is drawn on the screen.  Draw the Nichols grid with NGRID.
%
%       See also: LOGSPACE, NGRID, MARGIN, BODE, and NYQUIST.

%       Clay M. Thompson  7-6-90
%       Revised ACWG 6-21-92, PG 6-25-96
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.20 $  $Date: 2002/04/10 06:24:54 $


ni = nargin;
no = nargout;
% Check for demo and quick exit
if ni==0,
   eval('exresp(''nichols'')')
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
   nichols(sys,w);
else
   [magout,phase,w] = nichols(sys,w);
   [Ny,Nu,lw] = size(magout);
   magout = reshape(magout,[Ny*Nu lw]).';
   phase = reshape(phase,[Ny*Nu lw]).';
end

% end nichols
