function tran_func = sim2gen(sim_file);
%SIM2GEN Converts a Simulink block diagram to convolution code transfer function.
%
%WARNING: This is an obsolete function and may be removed in the future.

%       TRAN_FUNC = SIM2GEN(SIM_FILE) reads in a Simulink block diagram file
%       specified in the string SIM_FILE. The output TRAN_FUNC has the
%       form:
%                   | g11  g12 ... g1N |
%       TRAN_FUNC = | ......           |
%                   | gK1  gK2 ... gKN |
%       in which gIJ is the Ith input Jth output octal form transfer function.
%       For example gij = 65 represents the transfer function for Ith input
%       and Jth output g(D) = 1 + D + D^3 + D^5.
%       SIM_FILE should contain no subsystem. The SIMULINK file is built using
%       following blocks:
%           Memory    -- register
%           XOR Logic -- logic add
%           Inport    -- message input port
%           Outport   -- code output port
%       Currently, this function only processes the case when there is a
%       feedback loop.
%
%       See also ENCODE, DECODE, CONVENCO, OCT2GEN, SIM2TRAN.

%       Wes Wang 8/31/94, 10/11/95, 7/14/96.
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.16 $

if ~isstr(sim_file)
    error('SIMULINK file name should be a string in SIM2TRAN');
end;
exi = exist(sim_file);
% open the system
if exi ~= 4
    open_system(sim_file)
end;

blk_nam = get_param(sim_file,'blocks');
[n_blk, m_blk] = size(blk_nam);
% fetch block types.
blk_type = zeros(1, n_blk);
%assign 1--sum, 2--register, 3--inport, 4--outport.
sum_blk = [];   % XOR blocks.
mem_blk = [];   % Memory blocks.
out_blk = [];   % Output blocks.
inp_blk = [];   % Input block.

block_handle = zeros(n_blk, 1);
for i = 1 : n_blk
    block_handle(i) = get_param([sim_file, '/', blk_nam{i}], 'handle');
    blk_type_tmp = get_param([sim_file, '/', blk_nam{i}], 'BlockType');
    len_blk = length(blk_type_tmp);
    if (len_blk == 5)
        if blk_type_tmp == 'Logic'
	    if strcmp(get_param([sim_file, '/', blk_nam{i}], 'Operator'), 'XOR')
                sum_blk = [sum_blk, i];
                blk_type(i) = 1;
	    else
                error('In the linear convolutional code case, the Logic operation must be XOR.')
            end
        else
            error(['An illegal block exists in ',sim_file, ', conversion is terminated.']);
        end;
    elseif (len_blk == 3)
        if blk_type_tmp == 'Sum'
            sum_blk = [sum_blk, i];
            blk_type(i) = 1;
        else
            error(['An illegal block exists in ',sim_file, ', conversion is terminated.']);
        end;
    elseif (len_blk == 6)
        if blk_type_tmp == 'Memory'
            mem_blk = [mem_blk, i];
            blk_type(i) = 2;
        elseif blk_type_tmp == 'Inport'
            inp_blk = [inp_blk, i];
            blk_type(i) = 3;
        else
            error(['An illegal block exists in ',sim_file, ', conversion is terminated.']);
        end;
    elseif (len_blk == 7)
        if blk_type_tmp == 'Outport'
            out_blk = [out_blk, i];
            blk_type(i) = 4;
        else
            error(['An illegal block exists in ',sim_file, ', conversion is terminated.']);
        end;
    elseif (len_blk == 4)
        % other than the legal blocks, only Note can be used in the block diagram.
        if blk_type_tmp ~= 'Note'
            error(['An illegal block exists in ',sim_file, ', conversion is terminated.']);
        end;
    else
        error(['An illegal block exists in ',sim_file, ', conversion is terminated.']);
    end;    
end;

M = length(mem_blk);
N = length(out_blk);
K = length(inp_blk);
%if K > N
%    error('The convolution code should have more outputs than inputs');
%end;

% order the inports:
tmp = zeros(1,K);
for i = 1 : K
    index = str2num(get_param([sim_file, '/', blk_nam{inp_blk(i)}], 'Port'));
    if (index <= K) 
        if (tmp(index) == 0)
            tmp(index) = inp_blk(i);
        else
            error('The inport numbers must be sequentially ordered');
        end;
    else
        error('The inport numbers must be sequentially ordered');
    end;
end;
inp_blk = tmp;

% order the outports:
tmp = zeros(1,N);
for i = 1 : N
    index = str2num(get_param([sim_file, '/', blk_nam{out_blk(i)}], 'Port'));
    if (index <= N)
        if (tmp(index) == 0)
            tmp(index) = out_blk(i);
        else
            error('The outport numbers must be sequentially ordered');
        end;
    else
        error('The outport numbers must be sequentially ordered');
    end;
end;
out_blk = tmp;

% lines1--from block, lines2--from port, lines3--to block, lines4--to port, 
% lines5--use only if lines1 is zero, this indicate from block.
line_cell = get_param(sim_file, 'lines');

lines = lineprob([], line_cell, block_handle, [], []);

if ~isempty(find(lines==0))
    error('There are unconnected lines, please remove them.');
end;
a = zeros(M, M);
b = zeros(M, K);

% fix all states. fill up a and b matrix.
for i = 1 : M
    [a(i,:), b(i, :)] = simsum2(mem_blk(i), inp_blk, sum_blk, mem_blk, lines);
end;

if max(diag(a)) > 0
    error('There is a feedback loop. Please use SIM2GEN instead.')
end;

M = 0;
for i = 1 : length(out_blk)
    [gen_sub, pos_sub] = simsum(out_blk(i), inp_blk, sum_blk, mem_blk, lines);
    [n_sub, m_sub] = size(gen_sub);
    if i == 1
        tran_func = gen_sub;
        M = m_sub;
    else
        if M < m_sub
            tmp = tran_func;
            tran_func = [];
            for j = 1 : i-1
                tran_func = [tran_func, tmp(:, (j-1) * M +1 : j * M), zeros(n_sub, m_sub - M)];
            end;
            M = m_sub;
        else
            gen_sub = [gen_sub, zeros(n_sub, M - m_sub)];
        end;
        tran_func = [tran_func, gen_sub];
    end;
end;

code_param = [N, K, M-1, length(mem_blk)];
tran_func = oct2gen(tran_func, code_param);
% close the system
if exi ~= 4
    close_system(sim_file, 0);
end;
