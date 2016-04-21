function int_table = wcdma_secondinterleaver(numBits);
% WCDMA_SECONDINTERLEAVER Computes the interleaver table according to the specifications 
% for the Wcdma Second Interleaver block included in the Wcdma application examples.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/04/11 00:48:57 $

% Inter-column permutation pattern for 2nd interleaver
perm = [0 20 10 5 15 25 3 13 23 8 18 28 1 11 21 6 16 26 4 14 24 19 9 29 12 2 7 22 27 17];
perm = perm + 1;

% Assign number of Columns C2
nCols = 30;

% Determine the number of rows R2 of the matrix
nRows = ceil(numBits/nCols);

% Pad input bits with zeros
inputSeq = [1:numBits];
nZeros = nCols*nRows - numBits;
inputSeq = [inputSeq zeros(1,nZeros)];

% Write the input bit sequence into R2xC2 matrix row-by-row
inMatrix = reshape(inputSeq', nCols, nRows)';

% Perform the inter-column permutation
outMatrix = inMatrix(:,perm);

% Read the bit sequence of the block interleaver column-by-column
int_table = reshape(outMatrix, 1, nRows*nCols)';

% Perform Zero pruning
int_table = int_table(find(int_table ~= 0));