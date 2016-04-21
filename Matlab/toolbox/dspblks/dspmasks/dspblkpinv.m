function s = dspblkpinv
% DSPBLKPINV Signal Processing Blockset Pseudo Inverse block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.3.4.2 $ $Date: 2004/04/12 23:07:03 $

blk = gcbh;

% Setup port label structure:
	% 1 input (A)
	% 1 output (A+)
   s.i1 = 1; s.i1s = 'A'; 
   s.o1 = 1; s.o1s = 'A+';
    
% [EOF] dspblkpinv.m