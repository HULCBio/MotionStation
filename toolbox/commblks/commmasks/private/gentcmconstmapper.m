function cplxconstpts = gentcmconstmapper(trellis, constpts)
%GENTCMCONSTMAPPER Constellation points ordering for TCM 
%   CPLXCONSTPTS = GENTCMCONSTMAPPER(TRELLIS, CONSTPTS) outputs complex
% constellation points ordered as required by TCM. The input argument
% TRELLIS describes the trellis structure while CONSTPTS provides the
% set-partitioned constellation points.

%   Copyright 1996-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/07/30 02:48:38 $ 


% Initialization
cplxconstpts =[];

%-- Initialize trellis fields to variables
decout = trellis.outputs;
% Convert the outputs matrix in decimal to binary with numStates*numInputSymbols
% rows and log2(numOutputSymbols) columns
binout = de2bi(decout,'left-msb');
numInputSym = trellis.numInputSymbols;
numOutBits = log2(trellis.numOutputSymbols);
numStates  = trellis.numStates;
uncodedBitOutPos = zeros(1,numOutBits);

%-- Compute the position of coded and uncoded bits in output
for indx1 = 1:numInputSym
    % Compute the the sum of the individual output bits for each input symbol
    bitSumOverState  = sum(binout((indx1-1)*numStates +1 : indx1*numStates,:));
    % Store the column number that has sum of the individual bits zero for all 
    % possible states 
    [r1 c1] = find(bitSumOverState==0);
    % Save the position of th uncoded bit
    uncodedBitOutPos(1,c1) = 1;    
end

%-- Compute the number of coded and uncoded bits
numUncodedBits = sum(uncodedBitOutPos);
numCodedBits = numOutBits - numUncodedBits;

%-- Find all possible binary mapping for the M-ary number
possBitOut = de2bi(0:trellis.numOutputSymbols-1,'left-msb');
bitMap = zeros(trellis.numOutputSymbols, numOutBits);

%-- Find positions of uncoded and coded bits
[row2 col2] = find(uncodedBitOutPos==1);
[row3 col3] = find(uncodedBitOutPos==0);

%-- Shift the LSB bits to the uncoded bit positions since the uncoded bits are
%   the ones that determine the last stage(s) of set-partitioning
for indx2 = numUncodedBits:-1:1
    bitMap(:,col2(1,numUncodedBits - indx2 +1)) = possBitOut(:,numOutBits - numUncodedBits + indx2);
end

%-- Shift the MSB bits to the coded bit position since the coded bits are
%   the ones that determine the first stage(s) of set-partitioning
for indx3 = 1:numCodedBits
    bitMap(:,col3(1,numCodedBits - indx3 + 1)) = possBitOut(:,indx3);
end

%-- Sort the constellation points based on binary mapping
mtrx = sortrows([bi2de(bitMap,'left-msb') constpts.'],1);
cplxconstpts = mtrx(:,2);

% [EOF]