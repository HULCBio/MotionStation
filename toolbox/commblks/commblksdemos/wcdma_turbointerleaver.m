function int_table = wcdma_turbointerleaver(numBits)
% WCDMA_TURBOINTERLEAVER Computes the interleaver table according to the specifications 
% for the Wcdma Turbo Interleaver block included in the Wcdma application examples.

% Copyright 1996-2002 The MathWorks, Inc.
% $Revision: 1.2 $  $Date: 2002/04/11 00:49:04 $

% Check Parameters
if(~isscalar(numBits) | floor(numBits)~=numBits | numBits<40 | numBits >5114)
    errordlg('The number of input bits to the Turbo Interleaver must be an integer between 40 and 5114 inclusive.');
end

% Compute number of Rows (R)
if(40 <= numBits) & (numBits <=159)
    nRows=5;
elseif(((160 <= numBits) & (numBits <= 200)) | ((481 <= numBits) & (numBits <= 530)))
    nRows=10;
else
    nRows=20;
end

% Load Prime Number Table
load wcdma_primenumtable;

% Determine the prime number to be used in the intra-permutation
if((481 <= numBits) & (numBits <= 530))
    p=53;
    nCols = p;
else    
    pos = find(wcdma_primenumtable(:,1)>=((numBits/nRows)-1)); 
    p = wcdma_primenumtable(pos(1),1);

    if(numBits <= nRows*(p-1))
        nCols = p-1;
    elseif(nRows*(p-1) < numBits) & (numBits <= nRows*p)
        nCols = p;
    else
        nCols = p+1;
    end
end

% Step 1: Select a primitive root
v = wcdma_primenumtable(find(wcdma_primenumtable(:,1)==p),2);

% Construct the base sequence for intra-row permutation
s(1)=1;
for j = 2:p-1,
    s(j) = rem((v*s(j-1)), p);
end

% Determine q sequence
gcd_of_1 = find(gcd(wcdma_primenumtable(:,1),p-1)==1);
q = [1 wcdma_primenumtable(gcd_of_1(1:nRows-1,1),1)'];

% Compute r sequence by permuting q

if(nRows==5) | (nRows==10)
    T = [nRows-1:-1:0] + 1; %adding 1 for MATLAB array indexing   
elseif((( 2281 <= numBits) &(numBits <= 2480)) | ((3161 <=numBits) & (numBits <=3210)))
    T = [19 9 14 4 0 2 5 7 12 18 16 13 17 15 3 1 6 11 8 10] +1;
else
    T = [19 9 14 4 0 2 5 7 12 18 10 8 13 17 3 1 16 6 15 11] +1 ;
end
  
r = q(:,T);
 
% Perform Intra-row permutation
j = [0:p-2];
if nCols == p
    
    for i=1:nRows,
        U(i,:) = [s(rem(j*r(i), p-1)+1) 0] +1;
    end
    
elseif nCols == p+1
    
    for i=1:nRows,       
        U(i,:)=[s(rem(j*r(i), p-1)+1) 0 p]+1;
    end
    if numBits == nRows*nCols,
        u=U(nRows,1);
        U(nRows,1) = U(nRows,end);
        U(nRows,end) = u;
    end
    
elseif nCols == p-1
    
    for i=1:nRows,       
        U(i,:) = s(rem(j*r(i), p-1)+1)-1 +1; 
    end
end

% Generate Index vector
bitSeq = [1:numBits];

% Write the input bit sequence into a RxC rectangular matrix row-by-row
nZeros = (nRows*nCols) - numBits;
bitSeq = [bitSeq zeros(1,nZeros)];
inMatrix = reshape(bitSeq', nCols, nRows)';

% Perform intra-row permutation
for i=1:nRows,
    outMatrix(i,:) = inMatrix(i,U(i,:));
end

% Perform inter-row permutation
outMatrix = outMatrix(T,:);
   
% Read the bit sequence column-by-column
int_table = reshape(outMatrix, 1, nRows*nCols)';

% Perform Zero pruning
int_table = int_table(find(int_table ~= 0));