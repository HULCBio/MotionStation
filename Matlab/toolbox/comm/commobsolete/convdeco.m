function [msg, exp, codd] = convdeco(code, tran_func, tran_prob, plot_flag);
%CONVDECO Decodes a convolution code using the Viterbi algorithm.
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use VITDEC instead.

%       MSG = CONVDECO(CODE, TRAN_FUNC) decodes an encoded convolution
%       codeword CODE by using the Viterbi algorithm. The convolution code
%       transfer function is provided in octal form in TRANS_FUNC. All
%       elements in CODE should be binary. CODE is a matrix with the
%       column size the same as the code length. The output MEG is the
%       decoded output with the column size as the message length. This
%       format of command call is used for hard decision decoding. See
%       function OCT2GEN for the format of an octal form of transfer function
%       matrix. 
%       
%       [MSG, DIST] = CONVDECO(CODE, TRAN_FUNC) returns the Hamming distance
%       in each step of recovering the message.
%
%       MSG = CONVDECO(CODE, TRAN_FUNC, TRAN_PROB) decodes a convolution
%       codeword CODE by using the Viterbi algorithm. This format of command 
%       call is used for soft decision decoding. The element in CODE may not
%       be binary. TRAN_PROB specifies the transfer probability. TRAN_PROB is
%       a three row matrix with the first row containing the receiving range,
%       the second row specifying the probability of "zero" signal transfer
%       to the receiving range, and the third row specifying the probability 
%       of "one" signal transfer to the receiving range.
%       For example,
%       TRAN_PROB = [-Inf 1/10, 1/2, 9/10; 
%                     2/5, 1/3, 1/5, 1/15; 
%                    1/16, 1/8, 3/8, 7/16]
%       means that the "zero" signal has 2/5 probability in range (-Inf, 1/10],
%       1/3 in range (1/10, 1/2], 1/5 in range (1/2, 9/10], and 1/15 in 
%       range (9/10, Inf). The "one" signal has 1/16 probability in 
%       range (-Inf, 1/10], 1/8 in range (1/10, 1/2], 3/8 in range
%       (1/2, 9/10], 7/16 in range (9/10, Inf).
%
%       [MSG, REC_PROB] = CONVDECO(CODE, TRAN_FUNC, TRAN_PROB) returns the
%       likelihood in each step of determining MSG.
%
%       [MSG, REC_PROB, SURVIVOR] = CONVDECO(...) outputs the survivors of the
%       code.
%
%       [...] = CONVDECO(CODE, TRANS_FUNC, TRAN_PROB, PLOT_FLAG) plots the
%       trellis diagram for the decoding. PLOT_FLAG is a positive integer.
%       PLOT_FLAG is the figure number used to plot the diagram. In the
%       trellis diagram, yellow path is the possible survivor path; red path
%       is the survivor. The number in the state position is the metric or the
%       accumulated Hamming distance in  the BSC case. When PLOT_FLAG is not
%       an integer or it is a negative number, the function will not plot the
%       diagram. For a hard decision case, assign TRAN_PROB to 0. The plot is
%       not recommended when the size of CODE is large.
%
%       See also CONVENCO, OCT2GEN.

%       Wes Wang 8/6/94, 10/2/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.16 $

% routine check.
if nargin < 2
    error('Not enough input variables for CONVDECO.');
elseif nargin < 3
    expen_flag = 0;     % expense flag == 0; BSC code. == 1, with TRAN_PROB.
else
    [N, K] = size(tran_prob);
    if N < 3
        expen_flag = 0;
    else
        expen_flag = 1;
        expen_work = zeros(1, N); % work space.
%        this lines used for testing
%        tran_prob(2:3, :) = floor((log10(tran_prob(2:3, :)) + 1) * 17.3 + .5);
        tran_prob(2:3, :) = log10(tran_prob(2:3, :));
    end;
end;
if nargin < 4
    plot_flag = 0;
else
    if (plot_flag <= 0)
        plot_flag = 0;
    elseif floor(plot_flag) ~= plot_flag
        plot_flag = 0;
    end;
end;

% initial parameters.
[tran_func, code_param] = oct2gen(tran_func);
N = code_param(1);
K = code_param(2);
M = code_param(3);
[n_code, m_code] = size(code);
if m_code ~= N
    if n_code == 1
        code = code';
        [n_code, m_code] = size(code);
    else
        error('CODE length does not match the TRAN_FUNC dimension in CONVDECO.')
    end;
end;

for i = 1 : M+1
    G = [G ; tran_func(:, i:M+1:N*(M+1))];
end;

% A matrix:
A = eye(K * (M-1));
A = [zeros(K, K), zeros(K, length(A)); A, zeros(length(A), K)]; 

% state size    
states = zeros(length(A), 1);
num_state = length(states);

% B matrix:
B = [eye(K); zeros(length(A)-K, K)];

% C matrix
C = [];
for i = 1 : M
    C = [ C, G(i*K + 1 : (i + 1) * K, :)'];
end;

% D matrix
D = G(1:K, :)';

% The STD state number reachiable is
n_std_sta = 2^num_state;

% at the very begining, the current state number is 1, only the complete zeros.
cur_sta_num = 1;

% veraible to record the weight trace back to the first state.
% the column number is the state number - 1.
% the first line is the previous. The second line is the current.
nn_code = n_code * N * 1000;
expense = [ones(1, n_std_sta) * nn_code; zeros(1, n_std_sta)];
expense(1,1) = 0;

% the column number is the state number - 1.
% the contents is the state it transfered from.
trace   = - ones(1, n_std_sta);
trace(1) = 0;
trace_num = 0;
% the solution in each of the transfer as above.
% ith row is the transition input (msg) from ith row of trace to (i+1)th row of trace.
solut   = [];

% In the following, the code is assumed start from zero state and ending at the
% zero state.

K2 = 2^K;
[n_code, m_code] = size(code);

if plot_flag
    figure(plot_flag);
    delete(get(plot_flag,'child'))
    set(plot_flag, 'NextPlot','add', 'Clipping','off');
    axis([0, n_code, 0, n_std_sta-1]);
    handle_axis = get(plot_flag,'Child');
%    xlabel('time');
%    ylabel('state number')
%    set(handle_axis, 'Box', 'off', 'NextPlot','add');
    xx=text(0, 0, '0');
    set(xx,'Color',[0 1 1]);
    hold on
    set(handle_axis, 'Visible', 'off');
    for i = 0 : n_std_sta-1
%        text(-n_code/8, i, ['State ', num2str(i)]);
        text(-n_code/8, i, ['State ', num2str(bi2de(fliplr(de2bi(i,num_state))))]);
    end;
    text(n_code/2.1, -n_std_sta/15, 'Time');
%    set(handle_axis,'YTick',[0:n_std_sta-1],'YTickLabels',[0:n_std_sta-1]);
    set(handle_axis, 'Visible', 'off');
end;
% pause

for i = 1 : n_code
    % make room for one more storage.
    trace_num = trace_num + 1;
    trace = [trace; -ones(1, n_std_sta)];
    solut = [solut; zeros(1, n_std_sta)];
    % fill up trace and solut
    pre_state = find(trace(trace_num, :) >= 0);
    
    for j = 1 : length(pre_state)
        jj = pre_state(j) - 1;           % index number - 1 is the state.
        cur_sta = de2bi(jj, num_state)';
        if expen_flag
            for num_N = 1 : N
                expen_work(num_N) = max(find(tran_prob(1,:) <= code(i, num_N)));
            end;
        end;
        for num_k = 1 : K2
            inp = de2bi(num_k - 1, K)';
            out = rem(C * cur_sta + D * inp,2);
%            nex_sta = A * cur_sta + B * inp;
            nex_sta = [inp; cur_sta(1 : num_state - K)];
            nex_sta_de = bi2de(nex_sta') + 1;
            if expen_flag
                % find the expense by the transfer probability
                expen_0 = find(out' <= 0.5);
                expen_1 = find(out' > 0.5);
                loca_exp = sum([tran_prob(2,expen_work(expen_0)) 0])...
                                        +sum([tran_prob(3,expen_work(expen_1)) 0]);
            else
                loca_exp = sum(rem(code(i, :) + out', 2));
            end;
            % used for testing   disp([i, jj, num_k, loca_exp])

            if plot_flag
                if i==n_code
                    if nex_sta_de == 1
                        %plot([i-1+.1, i], [jj, nex_sta_de-1], 'w-.');
                        %plot([i-1+.1, i], [bi2de(fliplr(de2bi(jj,num_state))), bi2de(fliplr(de2bi(nex_sta_de-1, num_state)))], 'w-.')
                    end;
                else
                    %plot([i-1+.1, i], [jj, nex_sta_de-1], 'w-.');
                    %plot([i-1+.1, i], [bi2de(fliplr(de2bi(jj,num_state))), bi2de(fliplr(de2bi(nex_sta_de-1,num_state)))], 'w-.')
                end;
            end;

            if trace(trace_num + 1, nex_sta_de) < 0
                % nothing happened yet. Fill all information.
                % previous state.
                trace(trace_num + 1, nex_sta_de) = jj;
                % input information.
                solut(trace_num, nex_sta_de) = num_k - 1;
                % weighting/expense
                expense(2, nex_sta_de) = loca_exp;
            else
                % something happended before. Take a comparison.
                replace_flag = 0;
                if expen_flag
                    if (loca_exp + expense(1, jj+1)) > (expense(2, nex_sta_de) + expense(1, trace(trace_num+1,nex_sta_de)+1))
                        replace_flag = 1;
                    end;
                else
                    if (loca_exp + expense(1, jj+1)) < (expense(2, nex_sta_de) + expense(1, trace(trace_num+1,nex_sta_de)+1))
                        replace_flag = 1;
                    end;
                end;
                if replace_flag
                    % make a replacement other wise do nothing
                    % expense
                    % trace
                    % disp([nex_sta_de, loca_exp jj])
                    expense(2, nex_sta_de) = loca_exp;
                    solut(trace_num, nex_sta_de) = num_k - 1;
                    trace(trace_num + 1, nex_sta_de) = jj;
                end;
            end;
        end;
    end;


    % strike out the not necessary.
    for j = trace_num - 1 : -1 : 2
        pre_state = find(trace(j, :) >= 0);
        for num_k = 1 : length(pre_state)
            jj = pre_state(num_k) - 1;
            % in the case of a state has not been continued, it will be strike out.
            if isempty(find(trace(j + 1, :) == jj))
                trace(j, pre_state(num_k)) = -1;
            end;
        end;
    end;
    % rearrange the first line of expense.
    tmp = expense(1,:);
    for j = 1 : n_std_sta
        if trace(trace_num+1, j) >= 0
            expense(1,j) = expense(2,j) + tmp(trace(trace_num+1, j)+1);
        end;
    end;

    if plot_flag
        % plot only no computation function here.
        pre_state = find(trace(trace_num + 1, :) >= 0);
        if i == n_code
            pre_state = 1;
        end;
        for j = 1 : length(pre_state)
            jj = pre_state(j) - 1;
            %plot([i-1+.1, i], [trace(trace_num+1, jj+1), jj], 'y-')       
            plot([i-1+.1, i], [bi2de(fliplr(de2bi(trace(trace_num+1,jj+1),num_state))), bi2de(fliplr(de2bi(jj,num_state)))], 'y-')
            xx=[xx; text(i, bi2de(fliplr(de2bi(jj,num_state))), num2str(expense(1,jj+1)))];
            set(xx,'Color',[0 1 1]);
        end;
        drawnow
    end;

    % detect the possible converged result to reduce the working matrix size.
    trace_2_non_z = find(trace(2,:) >= 0);
    while length(trace_2_non_z) <= 1
        % cut the length and accumulate the message length.
        % not that trace(1,:) alwasy have one non-negative element.
        inp = de2bi(solut(1, trace_2_non_z), K);
        cur_sta = de2bi(find(trace(1,:) >= 0)-1, num_state);
        out = rem(C * cur_sta' + D * inp', 2);
        msg = [msg; inp];
        codd = [codd; out'];
        [n_msg, m_msg] = size(msg);
        if plot_flag
            % plot([n_msg-1+.1, n_msg], [find(trace(1,:)>=0)-1, trace_2_non_z-1], 'r-')
            yy=plot([n_msg-1+.1, n_msg], [bi2de(fliplr(de2bi(find(trace(1,:)>=0)-1,num_state))), bi2de(fliplr(de2bi(trace_2_non_z-1,num_state)))], 'r-');
            set(yy,'LineWidth',2)
        end;
        if expen_flag
            % find the expense by the transfer probability
            for num_N = 1 : N
                expen_work(num_N) = max(find(tran_prob(1,:) <= code(n_msg, num_N)));
            end;
            expen_0 = find(out' <= 0.5);
            expen_1 = find(out' > 0.5);
            loca_exp = sum([tran_prob(2,expen_work(expen_0)) 0])...
                          +sum([tran_prob(3,expen_work(expen_1)) 0]);
        else
            loca_exp = sum(rem(code(n_msg, :) + out', 2));
        end;
        exp = [exp; loca_exp];
        ind_exp = find(expense(1,:) ~= nn_code);
%        expense(1, ind_exp) = expense(1, ind_exp) - loca_exp;
        solut(1,:) = [];
        trace(1,:) = [];
        trace_num = trace_num - 1;
        trace_2_non_z = find(trace(2,:) >= 0);
    end;
end;

% trace up to the state ending at zero.
final_state = zeros(trace_num+1, 1);
final_solut = zeros(trace_num, 1);

% trace up the path.
final_state(trace_num+1) = trace(trace_num+1, 1);
for i = trace_num : -1 : 1
    final_state(i) = trace(i, final_state(i+1) + 1);
    final_solut(i) = solut(i, final_state(i+1) + 1);
end;

%
%for i = 2 : trace_num - M + 1
for i = 2 : trace_num+1
    if i <= trace_num
        inp = de2bi(final_solut(i), K);
    else
        inp = zeros(1,K);
    end;
    cur_sta = de2bi(final_state(i), num_state);
    out = rem(C * cur_sta' + D * inp', 2);
    msg = [msg; inp];
    codd = [codd; out'];
    [n_msg, m_msg] = size(msg);
    if plot_flag
        if (i <= trace_num)
            % plot([n_msg-1+.1, n_msg], [final_state(i), final_state(i+1)], 'r-')
            yy=plot([n_msg-1+.1, n_msg], [bi2de(fliplr(de2bi(final_state(i),num_state))), bi2de(fliplr(de2bi(final_state(i+1),num_state)))], 'r-');
        else
            %plot([n_msg-1+.1, n_msg], [final_state(i), 0], 'r-')
            yy=plot([n_msg-1+.1, n_msg], [bi2de(fliplr(de2bi(final_state(i),num_state))), 0], 'r-');
        end;
        set(yy,'LineWidth',2)    
    end;
    if expen_flag
        % find the expense by the transfer probability
        for num_N = 1 : N
            expen_work(num_N) = max(find(tran_prob(1,:) <= code(n_msg, num_N)));
        end;
        expen_0 = find(out' <= 0.5);
        expen_1 = find(out' > 0.5);
        loca_exp = sum([tran_prob(2,expen_work(expen_0)) 0])...
                      +sum([tran_prob(3,expen_work(expen_1)) 0]);
    else
        loca_exp = sum(rem(code(n_msg, :) + out', 2));
    end;
    exp = [exp; loca_exp];
end;

% cut the extra message length
[n_msg, m_msg] = size(msg);
msg(n_msg-M+1:n_msg, :) = [];
if plot_flag
    set(xx,'Color',[0 1 1]);
 hold off
end;
% end of CONVDECO.M

