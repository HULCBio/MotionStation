% WCDMA_LOADINITSPREADANDMOD Preloads workspace variables for the 
% Wcdmaspreadandmod model included in the Wcdma application examples.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/04/11 00:49:02 $

numBits = 40;
slotFormat = 12;
sprdFactor = 128;
dpchCode  = 10;
numChipsOut = 256;
scrCode = [63 0];
overSampling = 8;

rxSlotsDelay = 2;
rxDelay = 22;
numTapsChEst  = 21;
numTapsRRC = 96;

dopplerFreq = 486.1111;
snrdB = -3;
fingerEnables = [1 1 1 1];
fingerPhases = [0 0.260 0.521 0.781]*1.0e-006;
fingerPhasesTicks  = [0 8 16 24];
powerVector = [-5.5 -10 -15 -12 -12];       
fingerPowers = [0 -3 -6 -9];
            