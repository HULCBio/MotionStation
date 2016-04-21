function [msg, expen, codd] = viterbi(code, tran_func, leng, tran_prob, plot_flag);
%VITERBI
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use VITDEC instead.

%VITERBI Convolution decode using Viterbi algorithm.
%       MSG = VITERBI(CODE, TRAN_FUNC) uses the Viterbi algorithm to recover the
%       message in CODE with the transfer function matrix provided in TRAN_FUNC.
%       The transfer function matrix is provided in state system form.
%       CODE is received in a binary symmetric channel (BSC). All
%       elements in CODE should be binary. CODE is a matrix with the column
%       size the same as the code length. See function OCT2GEN for the format
%       of an octal form of transfer function matrix. 
%
%       MSG = VITERBI(CODE, TRAN_FUNC, LEN) keeps the trace memory length
%       no larger than LEN.
%       
%       MSG = VITERBI(CODE, TRAN_FUNC, LEN, TRAN_PROB) uses the Viterbi algorithm
%       to recover the message in CODE with the transfer function matrix provided
%       in TRAN_FUNC. TRAN_FUNC is in octal form. CODE is assumed to be
%       received in a discrete memoryless channel (DMC). The element in CODE
%       may not be in a binary form. TRAN_PROB is a parameter specifying the
%       transfer probability. TRAN_PROB is a three row matrix specifying the
%       transfer probability in soft decision case. The first row of TRAN_PROB
%       specifies the receiving range; the second row specifies the probability
%       of "zero" signal transfer probability to the receiving range; the third
%       row specifies the probability of "one" signal transfer probability to
%       the receiving range. For example,
%       TRAN_PROB = [-Inf 1/10, 1/2, 9/10; 
%                     2/5, 1/3, 1/5, 1/15; 
%                    1/16, 1/8, 3/8, 7/16]
%       means that transferred "zero" signal has 2/5 probability receiving in
%       range (-Inf, 1/10], 1/3 in range (1/10, 1/2], 1/5 in range 
%       (1/2, 9/10], and 1/15 in range (9/10, Inf). The "one" signal has
%       1/16 probability in range (-Inf, 1/10], 1/8 in range (1/10, 1/2], 
%       3/8 in range (1/2, 9/10], 7/16 in range (9/10, Inf). When TRAN_PROB is
%       assigned to be zero, this function processes hard-decision decode.
%       In order to do soft-decision decode,  you must use a three row matrix.
%       For more information, see the Tutorial chapter of the Communications 
%       Toolbox User's Guide. 
%
%       [MSG, DIST] = VITERBI(CODE, TRAN_FUNC) returns the Hamming distance
%       in each step of recovering the message.
%
%       [MSG, REC_PROB, SURVIVOR] = VITERBI(...) outputs the survivors of the
%       code.
%
%       [...] = VITERBI(CODE, TRANS_FUNC, LEN, TRAN_PROB, PLOT_FLAG) plots the
%       trellis diagram for the decoding.  PLOT_FLAG, a positive integer,
%       is the figure number to be used to plot the diagram. In the
%       trellis diagram, yellow paths are the possible paths; red paths are
%       the survivors. The number in the state position is the metric or the
%       accumulated Hamming distance in the BSC case. When PLOT_FLAG is not
%       an integer or it is a negative number, the function does not plot
%       the diagram. Note that the function computation is very slow if the
%       plot is required.
%
%       See also CONVENCO, OCT2GEN.

%       Wes Wang 8/6/94, 10/11/95.
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.19 $

% routine check.
if nargin < 2
   error('Not enough input variables for VITERBI.');
elseif nargin < 3
   leng = 0;
end;

if (exist('vitcore') == 3) 
  if isstr(tran_func)
    tran_func = sim2tran(tran_func);
  end;
  
  [len_m, len_n] = size(tran_func);
  if tran_func(len_m, len_n)>=0 & max(max(tran_func)) ~= Inf
    [tran_func, code_param] = oct2gen(tran_func);
    N = code_param(1);
    K = code_param(2);
    M = code_param(3);
    G = [];
    for i = 1 : M+1
      G = [G ; tran_func(:, i:M+1:N*(M+1))];
    end;
    
    a = eye(K * (M-1));
    a = [zeros(K, K), zeros(K, length(a)); a, zeros(length(a), K)]; 
    
    % B matrix:
    b = [eye(K); zeros(length(a)-K, K)];
    
    % C matrix
    c = [];
    for i = 1 : M
      c = [ c, G(i*K + 1 : (i + 1) * K, :)'];
    end;
      
    % D matrix
    d = G(1:K, :)';
    M = length(a);
    
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
  elseif tran_func(len_m, len_n) == -Inf
    N = tran_func(1, len_n);
    K = tran_func(1, len_n);
    M = tran_func(1, len_n);      
  end;
   
  % This part is only for detecting the size of CODE, see if its size matches the vitcore's reqirement.
  % This is only because there isn't input detection inside VITCORE.C and not encourage users to directly use it.

  [n_code, m_code] = size(code);
  if max (n_code, m_code) <= 1
    msg = floor(code);
    if nargout > 1
      expen = [];
      if nargout == 3
	codd = [];
      end;
    end;
    return;
  end;
  
  if min (n_code, m_code) == 1
    code = code(:);
    code = vec2mat(code, N);
  elseif m_code ~= N
    error('CODE length does not match the TRAN_FUNC dimension in VITERBI.')
  end;
  
  [n_code, m_code] = size(code);
  if n_code == 1
    code = [code; code*0];
  end;
  
  if nargin == 5
    eval('[msg, expen, codd]=vitcore(code, tran_func, leng, tran_prob, plot_flag);');
  elseif nargin == 4
    eval('[msg, expen, codd]=vitcore(code, tran_func, leng, tran_prob);');
  else
    eval('[msg, expen, codd]=vitcore(code, tran_func, leng);');
  end;
else
  % the case of unlimited delay and memory.
  [n_code, m_code] = size(code);
  if (leng <= 0) | (n_code <= leng)
    leng = n_code;
  end;
  if leng <= 1
    leng = 2;
  end;
  
  if nargin < 4
    expen_flag = 0; 			% expense flag == 0; BSC code. == 1, with TRAN_PROB.
  else
    [N, K] = size(tran_prob);
    if N < 3
      expen_flag = 0;
    else
      expen_flag = 1;
      expen_work = zeros(1, N); 	% work space.
      tran_prob(2:3, :) = log10(tran_prob(2:3, :));
    end;
  end;
  
  if nargin < 5
    plot_flag(1) = 0;
  else
    if (plot_flag(1) <= 0)
      plot_flag(1) = 0;
    elseif floor(plot_flag(1)) ~= plot_flag(1)
      plot_flag(1) = 0;
    end;
  end;
  
  if isstr(tran_func)
    tran_func = sim2tran(tran_func);
  end;
  % initial parameters.
  [A, B, C, D, N, K, M] = gen2abcd(tran_func);
  
  if m_code ~= N
    if n_code == 1
      code = code';
      [n_code, m_code] = size(code);
    else
      error('CODE length does not match the TRAN_FUNC dimension in VITERBI.')
    end;
  end;
  
  % state size
  if isempty(C)
    states = zeros(tran_func(2,1), 1);
  else
    states = zeros(length(A), 1);
  end;
  num_state = length(states);
  
  % The STD state number reachiable is
  n_std_sta = 2^num_state;
  
  PowPowM = n_std_sta^2;
  
  % at the very begining, the current state number is 1, only the complete zeros.
  cur_sta_num = 1;
  
  % the variable expense is divided into n_std_sta section of size n_std_sta
  % length vector for each row. expense(k, (i-1)*n_std_sta+j) is the expense of
  % state j transfering to be state i
  expense = ones(leng, PowPowM) * NaN;
  expense(leng, [1:n_std_sta]) = zeros(1, n_std_sta);
  solu = zeros(leng, PowPowM);
  solution = expense(1,:);
  
  K2 = 2^K;
  
  if plot_flag(1)
    plot_flag(1) = figure(plot_flag(1));
    drawnow;
    delete(get(plot_flag(1),'child'))
    set(plot_flag(1), 'NextPlot','add', 'Clipping','off');
    if length(plot_flag) >= 5
      set(plot_flag(1),'Position',plot_flag(2:5));
    end;
    axis([0, n_code, 0, n_std_sta-1]);
    handle_axis = get(plot_flag(1),'Child');
    xx=text(0, 0, '0');
    set(xx,'Color',[0 1 1]);
    hold on
    set(handle_axis, 'Visible', 'off');
    plot_w = plot(0, 0, 'w--');
    plot_y = plot(0, 0, 'y-');
    plot_r = plot(0, 0, 'r-');
    for i = 0 : n_std_sta-1
      text(-n_code/8, i, ['State ', num2str(bi2de(fliplr(de2bi(i,num_state))))]);
    end;
    text(n_code/2.1, -n_std_sta/15, 'Time');
    set(handle_axis, 'Visible', 'off');
    flipped = zeros(1, n_std_sta);
    for i = 1 : n_std_sta 
      flipped(i) =  bi2de(fliplr(de2bi(i-1, M)));
    end;
  end;
  
  pre_state = 1;
  inp_pre = de2bi([0:K2-1]', K);
  cur_sta_pre = de2bi([0:n_std_sta-1], M);
  starter = 0;
  msg = [];
  expen = [];
  codd = [];
  
  for i = 1 : n_code
    % make room for one more storage.
    trace_pre = rem(i-2+leng, leng) + 1; % previous line of the trace.
    trace_num = rem(i-1, leng) + 1; 	% current line of the trace.
    expense(trace_num,:) = solution;
    
    if expen_flag
      for j = 1 : length(pre_state)
	jj = pre_state(j) - 1; 		% index number - 1 is the state.
	cur_sta = cur_sta_pre(pre_state(j),:)';
	indx_j = (pre_state(j) - 1) * n_std_sta;
	for num_N = 1 : N
	  expen_work(num_N) = max(find(tran_prob(1,:) <= code(i, num_N)));
	end;
	for num_k = 1 : K2
               inp = inp_pre(num_k, :)';
               if isempty(C)
                  tran_indx = pre_state(j) + n_std_sta * (num_k - 1);
                  nex_sta = A(tran_indx, :)';
                  out = B(tran_indx, :)';
               else
                  out = rem(C * cur_sta + D * inp,2);
                  nex_sta = rem(A * cur_sta + B * inp, 2);
               end;
               nex_sta_de = bi2de(nex_sta') + 1;
               % find the expense by the transfer probability
               expen_0 = find(out' <= 0.5);
               expen_1 = find(out' > 0.5);
               loca_exp = sum([tran_prob(2,expen_work(expen_0)) 0])...
                  +sum([tran_prob(3,expen_work(expen_1)) 0]);
               tmp = (nex_sta_de-1)*n_std_sta + pre_state(j);
               if isnan(expense(trace_num, tmp))
                  expense(trace_num, tmp) = loca_exp;
                  solu(trace_num, nex_sta_de + indx_j) = num_k;
               elseif expense(trace_num, tmp) < loca_exp
                  expense(trace_num, tmp) = loca_exp;
                  solu(trace_num, nex_sta_de + indx_j) = num_k;
               end;
            end;
         end;
      else
         for j = 1 : length(pre_state)
            jj = pre_state(j) - 1;           % index number - 1 is the state.
            cur_sta = cur_sta_pre(pre_state(j),:)';
            indx_j = (pre_state(j) - 1) * n_std_sta;
            for num_k = 1 : K2
               inp = inp_pre(num_k, :)';
               if isempty(C)
                  tran_indx = (num_k - 1) * n_std_sta + pre_state(j);
                  nex_sta = A(tran_indx, :)';
                  out = B(tran_indx, :)';
               else
                  out = rem(C * cur_sta + D * inp,2);
                  nex_sta = rem(A * cur_sta + B * inp, 2);
               end;
               nex_sta_de = bi2de(nex_sta') + 1;
               loca_exp = sum(rem(code(i, :) + out', 2));
               tmp = (nex_sta_de-1)*n_std_sta + pre_state(j);
               if isnan(expense(trace_num, tmp))
                  expense(trace_num, tmp) = loca_exp;
                  solu(trace_num, nex_sta_de + indx_j) = num_k;
               elseif expense(trace_num, tmp) > loca_exp
                  expense(trace_num, tmp) = loca_exp;
                  solu(trace_num, nex_sta_de + indx_j) = num_k;
               end;
            end;
         end;
      end;
      
      aft_state = [];
      for j2 = 1 : n_std_sta
         if max(~isnan(expense(trace_num, [1-n_std_sta : 0] + j2*n_std_sta)))
            aft_state = [aft_state, j2];
         end
      end;
      
      % go back one step to re-arrange the lines.
      if (plot_flag(1))
         plot_curv_x = [];
         plot_curv_y = [];
         for j = 1 : n_std_sta
            tmp = expense(trace_num, (j-1)*n_std_sta+1: j*n_std_sta);
            if expen_flag
               expen_rec(j) = max(tmp(find(~isnan(tmp))));
            else
               expen_rec(j) = min(tmp(find(~isnan(tmp))));
            end;
            for j2 = 1 : length(tmp)
               if ~isnan(tmp(j2))
                  plot_curv_x = [plot_curv_x, i-1+.1, i, NaN];
                  plot_curv_y = [plot_curv_y, ...
                        flipped(j2), ...
                        flipped(j), NaN];
               end;
            end;
         end;
      end;
      
      %find out the plot lines:
      
      if plot_flag(1)
         % plot only; no computation function here.
         plot_curv_x = [get(plot_y, 'XData'), NaN, plot_curv_x];
         plot_curv_y = [get(plot_y, 'YData'), NaN, plot_curv_y];
         for j = 1 : length(aft_state)
            xx=[xx; text(i, flipped(aft_state(j)), num2str(expen_rec(aft_state(j))))];
            set(xx,'Color',[0 1 1]);
         end;
         %        plot(plot_curv_x, plot_curv_y, 'y-');
         set(plot_y, 'XData', plot_curv_x, 'YData', plot_curv_y);
         if i < leng
            drawnow
         end;
      end;
      
      sol = expense(trace_num,:);
      % decision making.
      if i >= leng
         trace_eli = rem(trace_num, leng) + 1;
         % strike out the unnecessary.
         for j_k = 1 : leng - 2
            j_pre = rem(trace_num - j_k - 1 + leng, leng) + 1;
            sol = vitshort(expense(j_pre, :), sol, n_std_sta, expen_flag);
         end;
         
         tmp = (ones(n_std_sta,1) * expense(trace_eli, [starter+1:n_std_sta:PowPowM]))';
         sol = sol + tmp(:)';
         
         if expen_flag
            loc_exp =  max(sol(find(~isnan(sol))));   
         else
            loc_exp =  min(sol(find(~isnan(sol))));
         end
         dec = find(sol == loc_exp);
         dec = dec(1);
         dec = rem((dec - 1), n_std_sta);
         
         inp = de2bi(solu(trace_eli, starter*n_std_sta+dec+1)-1, K);
         if isempty(C)
            tran_indx = pre_state(j) + n_std_sta * (num_k - 1);
            out = B(tran_indx, :)';
         else
            cur_sta = cur_sta_pre(starter+1, :)';
            out = rem(C * cur_sta + D * inp(:),2);
         end;
         
         msg = [msg; inp];
         codd = [codd; out'];
         [n_msg, m_msg] = size(msg);
         if nargout > 1
            if expen_flag
               % find the expense by the transfer probability
               expen_0 = find(out' <= 0.5);
               expen_1 = find(out' > 0.5);
               loc_exp = sum([tran_prob(2,expen_work(expen_0)) 0])...
                  +sum([tran_prob(3,expen_work(expen_1)) 0]);
            else
               loc_exp = sum(rem(code(n_msg, :) + out', 2));
            end
            expen = [expen; loc_exp];
         end;
         
         if plot_flag(1)
            plot_curv_x = [get(plot_r, 'XData'), n_msg-1+.1, n_msg, NaN];
            plot_curv_y = [get(plot_r, 'YData'), flipped(starter+1), flipped(dec+1), NaN];
            set(plot_r, 'XData', plot_curv_x, 'YData', plot_curv_y,'LineWidth',2);
            drawnow
         end;
         
         starter = dec;
      end; %(if i >= leng)
      pre_state = aft_state;
      aft_state = [];
   end;
   
   for i =  1 : leng-1
      sol = solution;
      trace_eli = rem(trace_num + i, leng) + 1;
      if i < leng-1
         sol(1:n_std_sta) = expense(trace_num, 1:n_std_sta);
         for j_k = 1 : leng - 2 - i
            j_pre = rem(trace_num - j_k - 1 + leng, leng) + 1;
            sol = vitshort(expense(j_pre, :), sol, n_std_sta, expen_flag);
         end;
         tmp = (ones(n_std_sta,1) * expense(trace_eli, [starter+1:n_std_sta:PowPowM]))';
         sol = sol + tmp(:)';
         if expen_flag
            loc_exp =  max(sol(find(~isnan(sol))));   
         else
            loc_exp =  min(sol(find(~isnan(sol))));
         end
         dec = find(sol == loc_exp);
         dec = dec(1);
         dec = rem((dec - 1), n_std_sta);
      else
         dec = 0;
      end;
      
      inp = de2bi(solu(trace_eli, starter*n_std_sta+dec+1)-1, K);
      cur_sta = de2bi(starter, num_state);
      out = rem(C*cur_sta' + D * inp', 2);
      msg = [msg; inp];
      codd = [codd; out'];
      [n_msg, m_msg] = size(msg);
      
      if nargout > 1
         if expen_flag
            % find the expense by the transfer probability
            expen_0 = find(out' <= 0.5);
            expen_1 = find(out' > 0.5);
            loc_exp = sum([tran_prob(2,expen_work(expen_0)) 0])...
               +sum([tran_prob(3,expen_work(expen_1)) 0]);
         else
            loc_exp = sum(rem(code(n_msg, :) + out', 2));
         end
         expen = [expen; loc_exp];
      end;
      
      if plot_flag(1)
         plot_curv_x = [get(plot_r, 'XData'), n_msg-1+.1, n_msg, NaN];
         plot_curv_y = [get(plot_r, 'YData'), flipped(starter+1), flipped(dec+1), NaN];
         set(plot_r, 'XData', plot_curv_x, 'YData', plot_curv_y,'LineWidth',2);
         drawnow
      end;
      starter = dec;
   end;
   
   
   % cut the extra message length
   [n_msg, m_msg] = size(msg);
   msg(n_msg-M+1:n_msg, :) = [];
   if plot_flag(1)
      set(xx,'Color',[0 1 1]);
      hold off
   end;
end;
% end of VITERBI.M
