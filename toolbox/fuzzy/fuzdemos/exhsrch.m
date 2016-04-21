function [input_index, elapsed_time] = ...
	exhsrch(in_n, trn_data, chk_data, input_name, mf_n, epoch_n)
%EXHSRCH Exhaustive search for input selection in ANFIS modeling
%	EXHSRCH performs an exhaustive search on selecting 1 to 4 inputs
%	from a set of input candidates for ANFIS modeling.
%	EXHSRCH will launches C(M, N) ANFIS modeling processes if we want
%	to select N inputs from M candidates. Therefore it might takes a
%	long time if M is moderately large and N is about the half of M.
%
%	Usage:
%	[INPUT_INDEX, ELAPSED_TIME] = ...
%		EXHSRCH(IN_N, TRN_DATA, CHK_DATA, INPUT_NAME, MF_N, EPOCH_N)
%
%	INPUT_INDEX: index of the inputs selected by EXHSRCH
%	ELAPSED_TIME: elapsed time in input selection
%	IN_N: number of inputs to be selected from the input candidates
%		(This is restricted to be from 1 to 4.)
%	TRN_DATA: original training data
%	CHK_DATA: original checking data
%	INPUT_NAME: input name for all input candidates
%		(Optional, default to 'in1', 'in2', 'in3', etc.)
%	MF_N: no. of membership function for each input
%		(Optional, default to 2.)
%	EPOCH_N: no. of training epochs for ANFIS
%		(Optional, default to 1.)
%	
%	Type EXHSRCH for a self demo on selecting inputs for automobile
%	MPG (miles per gallon) prediction.
%
%	See also SEQSRCH.

%	Copyright 1994-2002 The MathWorks, Inc. 
%	$Revision: 1.9 $
%	Roger Jang, August 1997

if nargin < 6, epoch_n = 1; end
if nargin < 5, mf_n = 2; end
if nargin == 3,
	input_name = 'in1';
	for i = 2:size(trn_data,2)-1,
		input_name = str2mat(input_name, ['in', num2str(i)]);
	end
end
if nargin < 3 & nargin ~= 0,
	error('Need at least three input arguments.');
end

if nargin == 0,	% Self demo (and test too)
	% Dryer data
	drydata;
	trn_data_n = 300;
	trn_data = data(1:trn_data_n, :);
	chk_data = data(trn_data_n+1:size(data,1), :);
	[input_index, elapsed_time] = exhsrch(2,trn_data,chk_data,input_name);
	fprintf('\nIndices of selected inputs:\n');
	disp(input_index);
	fprintf('Elapsed time in input selection: %.3f\n', elapsed_time);
	return;

	load bjdata.dat
	output = bjdata(:, 1);
	input = bjdata(:, 2:11); 
	data = [input output];
	input_name = str2mat('y(k)', 'y(k-1)', 'y(k-2)', 'y(k-3)', ...
		'u(k)', 'u(k-1)', 'u(k-2)', 'u(k-3)', 'u(k-4)', 'u(k-5)');
	trn_data = data(  1:145, :);
	chk_data = data(146:290, :);
	exhsrch(1, trn_data, chk_data, input_name, 3);
	exhsrch(2, trn_data, chk_data, input_name, 3);
	return;

	[data, input_name] = loadgas;
	trn_data = data(1:2:size(data, 1), :);
	chk_data = data(2:2:size(data, 1), :);
	exhsrch(1, trn_data, chk_data, input_name);
	exhsrch(2, trn_data, chk_data, input_name);
	exhsrch(3, trn_data, chk_data, input_name);
	exhsrch(4, trn_data, chk_data, input_name);
	return;
end

if in_n < 1 | in_n > 4,
	error([mfilename, ...
	' only selects 1 to 4 input variables from all input candidates.']);
end

all_in_n = size(trn_data, 2)-1;

t0 = clock;
% ======= Training options 
mf_type = 'gbellmf';
ss = 0.1;
ss_dec_rate = 0.5;
ss_inc_rate = 1.5;

anfis_n = prod(1:all_in_n)/(prod(1:in_n)*prod(1:(all_in_n-in_n)));
index = zeros(anfis_n, in_n);
trn_error = zeros(anfis_n, 1);
chk_error = zeros(anfis_n, 1);

if in_n == 1,
  % ====== Train ANFIS with different input variables
  fprintf('\nTrain %d ANFIS models, each with %d inputs selected from %d candidates...\n\n',...
    anfis_n, in_n, all_in_n);
  model = 1;
  for i=1:all_in_n,
    in = deblank(input_name(i, :));
    index(model, :) = [i];
    this_trn_data = trn_data(:, [i all_in_n+1]);
    this_chk_data = chk_data(:, [i all_in_n+1]);
    in_fismat = genfis1(this_trn_data, mf_n, mf_type);
    [trn_out_fismat t_err step_size chk_out_fismat c_err] = ...
	anfis(this_trn_data, in_fismat, ...
	[epoch_n nan ss ss_dec_rate ss_inc_rate], ...
	[0 0 0 0], this_chk_data, 1);
    trn_error(model) = min(t_err);
    chk_error(model) = min(c_err);
    fprintf('ANFIS model %d: %s', model, in);
    fprintf(' --> trn=%.4f,', trn_error(model));
    fprintf(' chk=%.4f', chk_error(model));
    fprintf('\n');
    model = model+1;
  end
elseif in_n == 2,
  % ====== Train ANFIS with different input variables
  fprintf('\nTrain %d ANFIS models, each with %d inputs selected from %d candidates...\n\n',...
    anfis_n, in_n, all_in_n);
  model = 1;
  for i=1:all_in_n,
    for j=i+1:all_in_n,
      in1 = deblank(input_name(i, :));
      in2 = deblank(input_name(j, :));
      index(model, :) = [i j];
      this_trn_data = trn_data(:, [i j all_in_n+1]);
      this_chk_data = chk_data(:, [i j all_in_n+1]);
      in_fismat = genfis1(this_trn_data, mf_n, mf_type);
      [trn_out_fismat t_err step_size chk_out_fismat c_err] = ...
	anfis(this_trn_data, in_fismat, ...
	[epoch_n nan ss ss_dec_rate ss_inc_rate], ...
	[0 0 0 0], this_chk_data, 1);
      trn_error(model) = min(t_err);
      chk_error(model) = min(c_err);
      fprintf('ANFIS model %d: %s %s', model, in1, in2);
      fprintf(' --> trn=%.4f,', trn_error(model));
      fprintf(' chk=%.4f', chk_error(model));
      fprintf('\n');
      model = model+1;
    end
  end
elseif in_n == 3,
  % ====== Train ANFIS with different input variables
  fprintf('\nTrain %d ANFIS models, each with %d inputs selected from %d candidates...\n\n',...
    anfis_n, in_n, all_in_n);
  model = 1;
  for i=1:all_in_n,
    for j=i+1:all_in_n,
      for k=j+1:all_in_n,
	in1 = deblank(input_name(i, :));
	in2 = deblank(input_name(j, :));
	in3 = deblank(input_name(k, :));
	index(model, :) = [i j k];
	this_trn_data = trn_data(:, [i j k all_in_n+1]);
	this_chk_data = chk_data(:, [i j k all_in_n+1]);
	in_fismat = genfis1(this_trn_data, mf_n, mf_type);
	[trn_out_fismat t_err step_size chk_out_fismat c_err] = ...
	  anfis(this_trn_data, in_fismat, ...
	  [epoch_n nan ss ss_dec_rate ss_inc_rate], ...
	  [0 0 0 0], this_chk_data, 1);
	trn_error(model) = min(t_err);
	chk_error(model) = min(c_err);
	fprintf('ANFIS model %d: %s %s %s', model, in1, in2, in3);
        fprintf(' --> trn=%.4f,', trn_error(model));
        fprintf(' chk=%.4f', chk_error(model));
        fprintf('\n');
	model = model+1;
      end
    end
  end
elseif in_n == 4,
  % ====== Train ANFIS with different input variables
  fprintf('\nTrain %d ANFIS models, each with %d inputs selected from %d candidates...\n\n',...
    anfis_n, in_n, all_in_n);
  model = 1;
  for i=1:all_in_n,
    for j=i+1:all_in_n,
      for k=j+1:all_in_n,
        for l=k+1:all_in_n,
	  in1 = deblank(input_name(i, :));
	  in2 = deblank(input_name(j, :));
	  in3 = deblank(input_name(k, :));
	  in4 = deblank(input_name(l, :));
	  index(model, :) = [i j k l];
	  this_trn_data = trn_data(:, [i j k l all_in_n+1]);
	  this_chk_data = chk_data(:, [i j k l all_in_n+1]);
	  in_fismat = genfis1(this_trn_data, mf_n, mf_type);
	  [trn_out_fismat t_err step_size chk_out_fismat c_err] = ...
	    anfis(this_trn_data, in_fismat, ...
	    [epoch_n nan ss ss_dec_rate ss_inc_rate], ...
	    [0 0 0 0], this_chk_data, 1);
	  fprintf('ANFIS model %d: %s %s %s %s', model, in1, in2, in3, in4);
          fprintf(' --> trn=%.4f,', trn_error(model));
          fprintf(' chk=%.4f', chk_error(model));
          fprintf('\n');
	  trn_error(model) = min(t_err);
	  chk_error(model) = min(c_err);
	  model = model+1;
        end
      end
    end
  end
end

% ====== Generate input_index
[a b] = min(trn_error);
input_index = index(b,:);

elapsed_time = etime(clock, t0);

% ====== The following is for plotting
% ====== Reordering according to training error
[a b] = sort(trn_error);
%b = flipud(b);		% List according to decreasing trn error
trn_error = trn_error(b);
chk_error = chk_error(b);
index = index(b, :);
% ====== Display training and checking errors
figTitle = ['ANFIS Input Selection: Select ', num2str(in_n), ...
	' inputs from ', num2str(all_in_n), ' candidates'];
figH = findobj(0, 'name', figTitle);
if isempty(figH),
	figH = figure(...
		'Name', figTitle, ...
		'NumberTitle', 'off');
else
	set(0, 'currentfig', figH);
end

x = (1:anfis_n)';
subplot(211);
plot(x, trn_error, '-', x, chk_error, '-', ...
     x, trn_error, 'o', x, chk_error, '*');
tmp = x(:, ones(1, 3))';
X = tmp(:);
tmp = [zeros(anfis_n, 1) max(trn_error, chk_error) nan*ones(anfis_n, 1)]';
Y = tmp(:);
hold on; plot(X, Y, 'g'); hold off;
axis([1 anfis_n -inf inf]);
set(gca, 'xticklabel', []);

% ====== Add text of input variables
if in_n == 1,
  for k = 1:anfis_n,
	text(x(k), -0.3, deblank(input_name(index(k,1), :)));
  end
elseif in_n == 2,
  for k = 1:anfis_n,
	text(x(k), -0.3, ...
	[deblank(input_name(index(k,1), :)) ' ' ...
	 deblank(input_name(index(k,2), :))]);
  end
elseif in_n == 3,
  for k = 1:anfis_n,
	text(x(k), -0.3, ...
	[deblank(input_name(index(k,1), :)) ' ' ...
	 deblank(input_name(index(k,2), :)) ' ' ...
	 deblank(input_name(index(k,3), :))]);
  end
elseif in_n == 4, 
  for k = 1:anfis_n,
	text(x(k), -0.3, ...
	[deblank(input_name(index(k,1), :)) ' ' ...
	 deblank(input_name(index(k,2), :)) ' ' ...
	 deblank(input_name(index(k,3), :)) ' ' ...
	 deblank(input_name(index(k,4), :))]);
  end
end

h = findobj(gcf, 'type', 'text');
set(h, 'rot', 90, 'fontsize', 10, 'hori', 'right');
drawnow
title('Training (Circles) and Checking (Asterisks) Errors');
ylabel('RMS Errors');
