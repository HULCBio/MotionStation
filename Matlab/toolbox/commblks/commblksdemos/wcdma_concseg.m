function [numBitsTrCh, numPadBits, numCodeWords, numBitsCodeWord] = wcdma_concseg(trBlkSetSize,trBlkSize,crcSize, errorCorr);
% WCDMA_CONCSEG Sets up workspace variables for the Wcdma
% Concatenation and Segmentation block included in the Wcdma application examples.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/04/11 00:49:03 $

% Type of Error Correction convention : {None=0, Conv 1/2=1, Conv 1/3=2, Turbo=3}

% Compute Number of Transport Blocks
numTrBlks = trBlkSetSize./trBlkSize;

% Compute Number of Bits per Transport Channel per TTI
numBitsTrCh = (trBlkSize+crcSize)*diag(numTrBlks);

% Maximum Code Block Size
%   no channel coding = unlimited (set to a very large number 1e12)
%   convolutional encoding = 504
%   turbo coding = 5114
Zmax = [1e12 504 504 5114];
Zmin = 40;

% Compute Number of Code Words
numCodeWords = ceil(numBitsTrCh./Zmax(errorCorr+1));

% Compute Number of Bits per Code Word
numBitsCodeWord = ceil(numBitsTrCh./numCodeWords);

% if numBitsTrCh <40  and Turbo Coding is used, then numBitsCodeWord = 40;
cond = (numBitsTrCh<Zmin) & (errorCorr == 3);
numBitsCodeWord = cond.*Zmin + not(cond).*numBitsCodeWord;

% Compute of Padding Bits
numPadBits = (numBitsCodeWord.*numCodeWords)-numBitsTrCh;






