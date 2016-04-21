function [a, b] = simsum2(crt_blk, inp_blk, sum_blk, mem_blk, lines)
%SIMSUM2 Generate one row of A and B matrices from the block diagram.
%
%WARNING: This is an obsolete function and may be removed in the future.

%       [A, B] = SIMSUM2(CRT_BLK, INP_BLK, SUM_BLK, MEM_BLK, LINES)
%       called by SIM2GEN2 for each output port transfer function 
%       is identification.
%       crt_blk -- current blk number.
%       inp_blk -- inport blocks. ordered by the port number.
%       sum_blk -- summary block.
%       mem_blk -- memory block.
%       lines   -- line connection. port to port number.
%
%       This function is a low-level function. It is not designed for general
%       use. It is only called by SIM2GEN and SIM2TRAN.

%       Wes Wang 12/5/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.14 $

% make space.
M = length(mem_blk);
K = length(inp_blk);
a = zeros(1, M);
b = zeros(1, K);

% validation check
index = find(lines(:,3) == crt_blk);
if isempty(index)
    return;
end;

% process for each connect port.
for i = 1 : length(index)
    ind = lines(index(i),1);
    ind_inp = find(inp_blk == ind);
    ind_mem = find(mem_blk == ind);
    ind_sum = find(sum_blk == ind);
    if ~isempty(ind_inp)
        % input block
        b(ind_inp) = 1;
    elseif ~isempty(ind_mem)
        % memory block
        a(ind_mem) = 1;
    elseif ~isempty(ind_sum)
        % sum block
        % recursive call.
        for j = 1 : length(ind_sum)
            [tmp_a, tmp_b] = simsum2(sum_blk(ind_sum(j)), inp_blk, sum_blk, mem_blk, lines);
            a = rem(a + tmp_a, 2);
            b = rem(b + tmp_b, 2);
        end;
    else
        error('The line is not well connected.');
    end;
end;
