% WCDMA_LOADINITMUXANDCODING Preloads workspace variables for the 
% Wcdmamuxandcoding model included in the Wcdma application examples.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/04/11 00:48:40 $

trBlkSetSize =  [244 100];    
trBlkSize = [244 100];     
numTrBlks = [1 1];
tti =   [20 40];         
crcSize = [16 12];
RMAttribute = [256 256];
errorCorr = [2 2];
numPhCH = 1;
posTrCh = [0 0];          
slotFormat = 11;

numBitsTrCh = [260 112];
numCodeWords = [1 1];
numPadBits = [0 0];
numBitsCodeWord = [260 122];
numBitsFirstInt = [686 308];
numBitsRF = [343 77];
numBitsRM =[804 360];
totalBitsDelay = [244 100];
