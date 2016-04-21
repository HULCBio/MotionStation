function [s,x,y] = dspblklevdurb(fcn)
% DSPBLKLEVDURB Signal Processing Blockset Levinson-Durbin block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.7.4.2 $ $Date: 2004/04/12 23:06:46 $

% Setup port label structure:
switch fcn
case 1,
   % 1 input (in)
   % 2 outputs (A,K)
   s.i1 = 1; s.i1s = ''; 
   s.i2 = 1; s.i2s = '';  %In
   s.o1 = 1; s.o1s = 'A';
   s.o2 = 2; s.o2s = 'K';  
   
case 2,
	% 1 input (in)
	% 1 output (A)
   s.i1 = 1; s.i1s = ''; 
   s.i2 = 1; s.i2s = '';  %In
   s.o1 = 1; s.o1s = '';
   s.o2 = 1; s.o2s = 'A';  %Val
   
case 3,
   % 1 input (in)
	% 1 output (K)
   s.i1 = 1; s.i1s = ''; 
   s.i2 = 1; s.i2s = '';  %In
   s.o1 = 1; s.o1s = '';
   s.o2 = 1; s.o2s = 'K';  %Idx
   
end
