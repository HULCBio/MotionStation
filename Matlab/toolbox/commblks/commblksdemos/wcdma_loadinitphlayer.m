% WCDMA_LOADINITPHLAYER Preloads workspace variables for the 
% Wcdmaphlayer model included in the Wcdma application examples.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.2.4.2 $  $Date: 2004/04/12 23:02:09 $

% Coding settings
trBlkSetSize = [244 100];
trBlkSize = [244 100];
numTrBlks = [1 1];
crcSize = [16 12];
tti = [20 40];
errorCorrMask = [2 2];
errorCorr = [2 2];
numBitsRF = [343 77];
numBitsRM = [804 360];
numPhCH = 1;
posTrCh = 0;
RMAttribute = [256 256];
totalBitsDelay = [488 200];

% Antenna settings
pilotBits = [254   206   221   204   237   254   252   236   222   255   221   239   236   207   207];
overSampling = 8;
slotFormat = 11;
sprdFactor = 128;
scrCode = [63 0];
dpchCode = 127;
numTapsChEst = 21;
numTapsRRC = 96;

% Channel settings
dopplerFreq = 486.1111;
snrdB = -3;
fingerEnables = [1 1 1 1];
fingerPhases = [0 0.260 0.521 0.781]*1.0e-006;
fingerPhasesTicks  = [0 8 16 24];
powerVector = [-5.5 -10 -15 -12 -12];       
fingerPowers = [0 -3 -6 -9];

          