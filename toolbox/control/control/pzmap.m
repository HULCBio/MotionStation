function [pout,z] = pzmap(a,b,c,d)
%PZMAP  Pole-zero map of LTI models.
%
%   PZMAP(SYS) computes the poles and (transmission) zeros of the
%   LTI model SYS and plots them in the complex plane.  The poles 
%   are plotted as x's and the zeros are plotted as o's.  
%
%   PZMAP(SYS1,SYS2,...) shows the poles and zeros of multiple LTI
%   models SYS1,SYS2,... on a single plot.  You can specify 
%   distinctive colors for each model, as in  
%      pzmap(sys1,'r',sys2,'y',sys3,'g')
%
%   [P,Z] = PZMAP(SYS) returns the poles and zeros of the system 
%   in two column vectors P and Z.  No plot is drawn on the screen.  
%
%   The functions SGRID or ZGRID can be used to plot lines of constant
%   damping ratio and natural frequency in the s or z plane.
%
%   For arrays SYS of LTI models, PZMAP plots the poles and zeros of
%   each model in the array on the same diagram.
%
%   See also POLE, ZERO, SGRID, ZGRID, RLOCUS, LTIMODELS.

%       Old syntax.
%warning(['This calling syntax for ' mfilename ' will not be supported in the future.'])
%	PZMAP(A,B,C,D) computes the eigenvalues and transmission zeros of
%	the state-space system (A,B,C,D).
%
%	PZMAP(NUM,DEN) computes the poles and zeros of the SISO polynomial
%	transfer function G(s) = NUM(s)/DEN(s) where NUM and DEN contain 
%	the polynomial coefficients in descending powers of s.  If the 
%	system has more than one output, then the transmission zeros are 
%	computed.
%
%	PZMAP(P,Z) plots the poles, P, and the zeros, Z, in the complex 
%	plane.  P and Z must be column vectors.

%	Clay M. Thompson  7-12-90
%	Revised: ACWG 6-21-92, AFP 12-1-95
%       Modified for Response Plots: A. DiVergilio, 5-1-2000
%	Copyright 1986-2002 The MathWorks, Inc. 
%	$Revision: 1.14 $  $Date: 2002/04/10 06:25:18 $

ni = nargin;
no = nargout;

switch ni
case 2
   [nd,md] = size(b);
   if (md<=1),
      % Assume Pole-Zero form
      p = a;
      z = b;
      sys = zpk(b,a,1);
   else
      % Transfer function form
      sys = tf(a,b);
   end

case 4
   % State space system 
   sys = ss(a,b,c,d);

otherwise
   error('Wrong number of input arguments.');
end

if no
   % Return output
   [pout,z] = pzmap(sys);
else
   % Create response plot
   pzmap(sys);
end

% end pzmap
