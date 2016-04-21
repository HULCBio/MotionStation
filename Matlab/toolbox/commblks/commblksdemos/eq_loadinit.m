% EQ_LOADINIT Preloads workspace variables for the Equalizer model 

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.1 $  $Date: 2002/05/17 16:43:48 $


chCoeff = [1 -0.3 0.5 0.1];
numTaps = 6;
mu      = 0.1;
ic      = [0.5 0.5];
sData   = 100;
Mconst  = 16;
delta_opt = 6;
