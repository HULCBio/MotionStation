function int_table = wcdma_firstinterleaver(numBits, tti);
% WCDMA_FIRSTINTERLEAVER Computes the interleaver table according to the specifications 
% for the Wcdma First Interleaver block included in the Wcdma application examples.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/04/11 00:49:08 $

% Inter-column permutation patterns for 1st Interleaving
seq10 = [0];
seq20 = [0 1];
seq40 = [0 2 1 3];
seq80 = [0 4 2 6 1 5 3 7];

switch (tti)
case 10
    perm = seq10+1;
case 20
    perm = seq20+1;
case 40
    perm = seq40+1;
case 80
    perm = seq80+1;
end

% Compute Number of Columns C1
nCols = tti/10;

% Compute Number of Rows R1
nRows = numBits/nCols;

% Write the input bit sequence into R1xC1 matrix row-by-row
inputSeq = [1:numBits];
inMatrix = reshape(inputSeq', nCols, nRows)';

% Perform inter-column permutation based on the above pattern  
outMatrix = inMatrix(:,perm);

% Read the bit sequence of the block interleaver column-by-column
int_table = reshape(outMatrix, 1, nRows*nCols)';



