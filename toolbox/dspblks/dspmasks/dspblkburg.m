function [s] = dspblkburg(fcn)
% DSPBLKBURG Signal Processing Blockset Burg block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/12 23:06:04 $

% Setup port label structure:
switch fcn
case 1,
   % 1 input (in)
   % 2 outputs (A,K)
   s.o1 = 1; s.o1s = 'A';
   s.o2 = 2; s.o2s = 'K';  
   
case 2,
	% 1 input (in)
	% 1 output (A)
   s.o1 = 1; s.o1s = '';
   s.o2 = 1; s.o2s = 'A';  %Val
   
case 3,
   % 1 input (in)
	 % 1 output (K)
   s.o1 = 1; s.o1s = '';
   s.o2 = 1; s.o2s = 'K';  %Idx
   
end
s.o3 = s.o2+1; s.o3s = 'G';
