function [align1,align2,score] = diffcode(seq1,seq2)
%DIFFCODE  Global alignment algorithm applied to file diffs
%   [align1,align2,score] = DIFFCODE(seq1,seq2)
% 
%   seq1 = cell array of lines of code for file 1
%   seq2 = cell array of lines of code for file 2
%
%   Uses the Needleman-Wunsch global alignment algorithm.

% Copyright 1984-2003 The MathWorks, Inc.

% Constants for use in backtrace step
north = uint8(1);
northwest = uint8(2);
west = uint8(3);

% Use a simple hash to speed comparison between the two files
seq1Hash = zeros(size(seq1));
seq2Hash = zeros(size(seq2));
for n = 1:length(seq1)
    if isempty(seq1{n})
        seq1Hash(n) = 0;
    else
        seq1Hash(n) = sum(seq1{n} .* (1:length(seq1{n})));
    end
end
for n = 1:length(seq2)
    if isempty(seq2{n})
        seq2Hash(n) = 0;
    else
        seq2Hash(n) = sum(seq2{n}.*(1:length(seq2{n})));
    end
end

n = length(seq1)+1;
m = length(seq2)+1;
F = zeros(m,n);
% The next line is a memory-friendly way to get index = zeros(m,n);
index(m,n) = uint8(0);

for i=1:m,
    index(i,1) = west;
end

for j = 1:n,
    index(1,j) = north;
end

% i steps through sequence 2
for i = 2:m,
    % j steps through sequence 1
    for j = 2:n,
        res1 = F(i-1,j-1) + (seq2Hash(i-1)==seq1Hash(j-1));
        res2 = F(i-1,j);
        res3 = F(i,j-1);
        
        % This is a JIT-friendly version of max
        if res1 >= res2
            if res1 >= res3
                maxpath = 1;
            else
                maxpath = 3;
            end
        else
            if res2 >= res3
                maxpath = 2;
            else
                maxpath = 3;
            end
        end
        
        switch maxpath
            case 1
                % Match the string
                index(i,j) = northwest;
                F(i,j) = F(i-1,j-1) + (seq2Hash(i-1)==seq1Hash(j-1));

            case 2
            % Skip west
            index(i,j) = west;
            F(i,j)=F(i-1,j);

            case 3
                % Skip north
                index(i,j) = north;
                F(i,j)=F(i,j-1);
        end
    end
end

align1 = [];
align2 = [];

i = m;
j = n;
score = F(end,end);

% Backtrace algorithm to determine final sequence
while (i>1) || (j>1)
    nextJump = index(i,j);
    if (nextJump == north)
        align1 = [j-1 align1];
        align2 = [0 align2];
        nexti=i;
        nextj=j-1;
    elseif (nextJump == west)
        align1 = [0 align1];
        align2 = [i-1 align2];
        nexti = i-1;
        nextj = j;
    else
        align1 = [j-1 align1];
        align2 = [i-1 align2];
        nexti=i-1;
        nextj=j-1;
    end
    i=nexti;
    j=nextj;
end
