function tran_func = sim2tran(sim_file);
%SIM2TRAN Converts a Simulink block diagram to convolution code transfer function.
%
%WARNING: This is an obsolete function and may be removed in the future.

%       TRAN_FUNC = SIM2TRAN(SIM_FILE) reads in a Simulink block diagram file
%       specified in the string SIM_FILE. The function outputs TRAN_FUNC in the
%       form 
%                   | a11  a12 ... a1M b11 b12 ... b1K N   |
%                   | ......           ....            K   |
%                   | aMM  aMM ... aMM bM1 bM2 ... bMK M   |
%       TRAN_FUNC = | c11  c12 ... c1M d11 d12 ... d1K 0   |
%                   | ......           ......          0   |
%                   | cN1  cN2 ... cNM dN1 dN2 ... dNK -Inf|
%       The transfer function has the form 
%           x(k+1) = A x(k) + B u(k)
%           y(k)   = C x(k) + D u(k)
%       where A, B, C, D are binary matrices.
%
%       SIM_FILE should contain no subsystems. The SIMULINK file is built using
%       following blocks:
%           Memory    -- register
%           XOR Logic -- logic add
%           Inport    -- message input port
%           Outport   -- code output port
%       Currently, this function only processes the case when there is a
%       feedback loop.
%
%       See also ENCODE, DECODE, CONVENCO, SIM2GEN, SIMSUM, SIMSUM2.

%       Wes Wang 12/4/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.20 $

if ~isstr(sim_file)
    error('SIMULINK file name should be a string in SIM2TRAN');
end;

% open the system
exi = isempty(find_system('SearchDepth',0,'Name', sim_file));
if exi
  if exist(sim_file)
    open_system(sim_file)
  else
    error(['Simulink block diagram ''', sim_file, ''' is not in your path.'])
  end
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

com_flag = 0;
logi_flag = 0;
block_handle = zeros(n_blk, 1);
for i = 1 : n_blk
    block_handle(i) = get_param([sim_file, '/', blk_nam{i}], 'handle');
    blk_type_tmp = get_param([sim_file, '/', blk_nam{i}], 'BlockType');
    len_blk = length(blk_type_tmp);
    if (len_blk == 3)
        if blk_type_tmp == 'Sum'
            sum_blk = [sum_blk, i];
            blk_type(i) = 1;
        else
            if blk_type_tmp ~= 'Not'
                error(['An illegal block exists in ',sim_file, ', conversion is terminated.']);
            end
        end;
    elseif (len_blk == 6)
        if blk_type_tmp == 'Memory'
            mem_blk = [mem_blk, i];
            blk_type(i) = 2;
        elseif blk_type_tmp == 'Inport'
            inp_blk = [inp_blk, i];
            blk_type(i) = 3;
        else
            if blk_type_tmp(1:4) ~= 'Note'
                error(['An illegal block exists in ',sim_file, ', conversion is terminated.']);
            end;
        end;
    elseif (len_blk == 7)
        if blk_type_tmp == 'Outport'
            out_blk = [out_blk, i];
            blk_type(i) = 4;
        else
            if blk_type_tmp(1:4) ~= 'Note'
                error(['An illegal block exists in ',sim_file, ', conversion is terminated.']);
            end;
        end;
    elseif (len_blk == 4)
        % other than the legal blocks, only Note can be used in the block diagram.
        if blk_type_tmp ~= 'Note'
            error(['An illegal block exists in ',sim_file, ', conversion is terminated.']);
        end;
    elseif (len_blk == 9)
        if blk_type_tmp == 'UnitDelay'
            com_flag = 1;
        else
            if blk_type_tmp(1:4) ~= 'Note'
                error(['An illegal block exists in ',sim_file, ', conversion is terminated.']);
            end;
        end;
    elseif (len_blk == 5)
        if blk_type_tmp == 'Logic'
            sum_blk = [sum_blk, i];
            blk_type(i) = 1;
            blk_ope = get_param([sim_file, '/', blk_nam{i}], 'Operator');
            if ~strcmp(blk_ope, 'XOR')
                logi_flag = 1;
            end;
        else
            if blk_type_tmp(1:4) ~= 'Note'
                error(['An illegal block exists in ',sim_file, ', conversion is terminated.']);
            end;
        end;
    else
        error(['An illegal block exists in ',sim_file, ', conversion is terminated.']);
    end;    
end;

if com_flag
    tran_func = sim2logi(sim_file);
    return
end;

if logi_flag
    error('Illegal operation in Logical operator, Replace memory block with Unit Delay block and try a different form.');
end;
M = length(mem_blk);
N = length(out_blk);
K = length(inp_blk);
%if K > N
%    error('The convolution code should have more outputs than inputs.');
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
    error('There are unconnected lines, please remove them before proceeding.');
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
a = zeros(M, M);
b = zeros(M, K);
c = zeros(N, M);
d = zeros(N, K);
% fix all states. fill up a and b matrix.
for i = 1 : M
    [a(i,:), b(i, :)] = simsum2(mem_blk(i), inp_blk, sum_blk, mem_blk, lines);
end;
% fix all output ports. fill up c and d matrix.
for i = 1 : N
    [c(i,:), d(i, :)] = simsum2(out_blk(i), inp_blk, sum_blk, mem_blk, lines);
end;

tran_func = [a b; c d];
[len_m, len_n] = size(tran_func);
if len_m < 4
    tran_func = [tran_func; zeros(4-len_m, len_n)];
    [len_m, len_n] = size(tran_func);
end;
tran_func = [tran_func zeros(len_m, 1)];
len_n = len_n + 1;
tran_func(1, len_n) = N;
tran_func(2, len_n) = K;
tran_func(3, len_n) = M;
tran_func(len_m, len_n) = -Inf;

% close the system
if exi
    close_system(sim_file, 0);
end;
