function trt = htruthtb(g)
%HTRUTHTB Generates a Hamming code truth table.
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use SYNDTABLE instead.

%       TRT = HTRUTHTB(G) produces a truth table for single error-correction
%       code having codeword length N and message length K.  G is either a 
%       K-by-N generator matrix or an (N-K)-by-N parity-check matrix.  TRT is
%       an (N+1)-by-N binary matrix.  The rth row of TRT is the correction 
%       vector for a received binary codeword whose syndrome has decimal
%       integer value r-1.  The syndrome of a received codeword is its 
%       product with the transpose of the parity-check matrix. 
%
%       See also HAMMGEN, DECODE.

%       Wes Wang 6/17/94, 10/10/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.17 $

[k, n] = size(g);
if k > n
    g = g';
     [k, n] = size(g);
end;

if max(max(eye(k) - g(:, n-k+1:n))) > 0
    h = g;
else
    h = gen2par(g);
    [k, n] = size(h);
end;

if max(max(eye(k) - h(:, 1:k))) > 0
    error('The input matrix is neither a generator nor a parity-check matrix.')
end;

%construct a truth table
trt = [zeros(1, n); eye(n)];
hh = [zeros(1,k); fliplr(h')];

% reorder the truth table based on h.
hh = bi2de(hh)+1;
%trt(hh,:) = trt(hh, :);
trt(hh,:) = trt;
trt(size(trt,1)+1:2^k, :) = zeros(2^k-size(trt,1), size(trt, 2));

%--end of htruthtb--
