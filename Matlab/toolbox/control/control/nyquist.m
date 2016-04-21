function [reout,im,w] = nyquist(a,b,c,d,iu,w)
%NYQUIST  Nyquist frequency response of LTI models.
%
%   NYQUIST(SYS) draws the Nyquist plot of the LTI model SYS
%   (created with either TF, ZPK, SS, or FRD).  The frequency range 
%   and number of points are chosen automatically.  See BODE for  
%   details on the notion of frequency in discrete-time.
%
%   NYQUIST(SYS,{WMIN,WMAX}) draws the Nyquist plot for frequencies
%   between WMIN and WMAX (in radians/second).
%
%   NYQUIST(SYS,W) uses the user-supplied vector W of frequencies 
%   (in radian/second) at which the Nyquist response is to be evaluated.  
%   See LOGSPACE to generate logarithmically spaced frequency vectors.
%
%   NYQUIST(SYS1,SYS2,...,W) plots the Nyquist response of multiple
%   LTI models SYS1,SYS2,... on a single plot.  The frequency vector
%   W is optional.  You can also specify a color, line style, and marker 
%   for each system, as in  
%      nyquist(sys1,'r',sys2,'y--',sys3,'gx').
%
%   [RE,IM] = NYQUIST(SYS,W) and [RE,IM,W] = NYQUIST(SYS) return the
%   real parts RE and imaginary parts IM of the frequency response 
%   (along with the frequency vector W if unspecified).  No plot is 
%   drawn on the screen.  If SYS has NY outputs and NU inputs,
%   RE and IM are arrays of size [NY NU LENGTH(W)] and the response 
%   at the frequency W(k) is given by RE(:,:,k)+j*IM(:,:,k).
%
%   See also BODE, NICHOLS, SIGMA, FREQRESP, LTIVIEW, LTIMODELS.

% Old help
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%NYQUIST Nyquist frequency response for continuous-time linear systems.
%   NYQUIST(A,B,C,D,IU) produces a Nyquist plot from the inputs
%   IU to all the outputs of the system:             
%               .                                    -1
%               x = Ax + Bu             G(s) = C(sI-A) B + D  
%               y = Cx + Du      RE(w) = real(G(jw)), IM(w) = imag(G(jw))
%
%   The frequency range and number of points are chosen automatically.
%
%   NYQUIST(NUM,DEN) produces the Nyquist plot for the polynomial 
%   transfer function G(s) = NUM(s)/DEN(s) where NUM and DEN contain
%   the polynomial coefficients in descending powers of s. 
%
%   NYQUIST(A,B,C,D,IU,W) or NYQUIST(NUM,DEN,W) uses the user-supplied
%   freq. vector W which must contain the frequencies, in radians/sec,
%   at which the Nyquist response is to be evaluated.  When invoked 
%   with left hand arguments,
%       [RE,IM,W] = NYQUIST(A,B,C,D,...)
%       [RE,IM,W] = NYQUIST(NUM,DEN,...) 
%   returns the frequency vector W and matrices RE and IM with as many
%       columns as outputs and length(W) rows.  No plot is drawn on the 
%   screen.
%   See also: LOGSPACE,MARGIN,BODE, and NICHOLS.

%   J.N. Little 10-11-85
%   Revised ACWG 8-15-89, CMT 7-9-90, ACWG 2-12-91, 6-21-92, 
%               AFP 2-23-93, 10-1-94
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.18 $  $Date: 2002/04/10 06:24:57 $

ni = nargin;
no = nargout;
% Check for demo and quick exit
if ni==0,
   eval('exresp(''nyquist'')')
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
   nyquist(sys,w);
else
   [reout,im,w] = nyquist(sys,w);
   [Ny,Nu,lw] = size(reout);
   reout = reshape(reout,[Ny*Nu lw]).';
   im = reshape(im,[Ny*Nu lw]).';
end

% end nyquist
