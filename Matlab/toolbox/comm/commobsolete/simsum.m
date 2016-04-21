function [gen, pos] = simsum(crt_blk, inp_blk, sum_blk, mem_blk, lines)
%SIMSUM generates the output from a given current block.
%
%WARNING: This is an obsolete function and may be removed in the future.

%       GEN = SIMSUM(CRT_BLK, INP_BLK, SUM_BLK, MEM_BLK, LINES)
%       is called by SIM2GEN for each output port transfer function 
%       identification.
%       crt_blk -- current block number.
%       inp_blk -- inport blocks. ordered by the port number.
%       sum_blk -- summary block.
%       mem_blk -- memory block.
%       lines   -- line connection. port to port number.
%
%       This function is a low-level function. It is not designed for general
%       use. It is only called by SIM2GEN.

%       Wes Wang 10/11/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.12 $

% make space.
gen = zeros(length(inp_blk), 1);
pos = gen;

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
        gen(ind_inp, 1) = 1;
        pos(ind_inp, 1) = ind_inp;
    elseif ~isempty(ind_mem)
        % memory block
        mem_len = 1;
        indd = find(lines(:,3) == ind);
        if isempty(indd)
            error('Lines are not connected.')
        end;
        ind_nex = lines(indd,1);
        while ~isempty(find(mem_blk == ind_nex))
            mem_len = mem_len + 1;
            indd = find(lines(:,3) == ind_nex);
            if isempty(indd)
                error('Lines are not connected.')
            end;
            ind_nex = lines(indd,1);
        end;
        ind_inp = find(inp_blk == ind_nex);
        ind_sum = find(sum_blk == ind_nex);
        if ~isempty(ind_inp)
            [n,m] = size(gen);
            if m < mem_len + 1
                gen = [gen, zeros(n, mem_len + 1 - m)];
            end;
            gen(ind_inp, mem_len + 1) = 1;
            pos(ind_inp, 1) = ind_inp;
        elseif ~isempty(ind_sum)
            % recursive call.
            [gen_sub, pos_sub] = simsum(sum_blk(ind_sum), inp_blk, sum_blk, mem_blk, lines);
            ind_noz = find(pos_sub >0);
            for jj = 1:length(ind_noz)
                j = ind_noz(jj);
                ind_thr = max(find(gen_sub(j,:) > 0));
                [n,m] = size(gen);
                if m < ind_thr + mem_len
                    gen = [gen, zeros(n, ind_thr + mem_len - m)];
                end;
                [n,m] = size(gen);                                
                gen(j, mem_len + 1 : mem_len + ind_thr) = rem(gen(j, mem_len + 1 : mem_len + ind_thr) + gen_sub(j, 1 : ind_thr), 2);  
                pos(j) = pos_sub(j);
            end;
        else
            error('The line is not well connected.');
        end;
    elseif ~isempty(ind_sum)
        % sum block
        % recursive call.
        [gen_sub, pos_sub] = simsum(sum_blk(ind_sum), inp_blk, sum_blk, mem_blk, lines);
        ind_noz = find(pos_sub > 0);
        for jj = 1 : length(ind_noz)
            j = ind_noz(jj);
            ind_thr = max(find(gen_sub(j, :) > 0));
            [n, m] = size(gen);
            if m < ind_thr
                gen = [gen, zeros(n, ind_thr - m)];
            end;
            [n, m] = size(gen);                               
            gen(j,1:ind_thr) = rem(gen(j,1:ind_thr) + gen_sub(j, 1 : ind_thr), 2);  
            pos(j) = pos_sub(j);
        end;
    else
        error('The line is not well connected.');
    end;
end;
