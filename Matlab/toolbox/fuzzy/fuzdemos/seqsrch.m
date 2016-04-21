function [input_index, elapsed_time] = ...
	seqsrch(in_n, trn_data, chk_data, input_name, mf_n, epoch_n)
%SEQSRCH Sequential forward search for input selection in ANFIS modeling
%	SEQSRCH performs a sequential forward search on selecting 1 to 4 inputs
%	from a set of input candidates for ANFIS modeling.
%	SEQSRCH will launches (2*M-N+1)*N/2 ANFIS modeling processes if we want
%	to select N inputs from M candidates.
%
%	Usage:
%	[INPUT_INDEX, ELAPSED_TIME] = ...
%		SEQSRCH(IN_N, TRN_DATA, CHK_DATA, INPUT_NAME, MF_N, EPOCH_N)
%
%	INPUT_INDEX: index of the inputs selected by SEQSRCH
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
%	Type SEQSRCH for a self demo on selecting inputs for automobile
%	MPG (miles per gallon) prediction.
%
%	See also EXHSRCH.

%	Copyright 1994-2002 The MathWorks, Inc. 
%	$Revision: 1.8 $
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
	[input_index, elapsed_time] = seqsrch(3,trn_data,chk_data,input_name);
	fprintf('\nIndices of selected inputs:\n');
	disp(input_index);
	fprintf('Elapsed time in input selection: %.3f\n', elapsed_time);
	return;

	% Box-Jenkin gas furnace data
	load bjdata.dat
	output = bjdata(:, 1);
	input = bjdata(:, 2:11); 
	data = [input output];
	input_name = str2mat('y(k)', 'y(k-1)', 'y(k-2)', 'y(k-3)', ...
		'u(k)', 'u(k-1)', 'u(k-2)', 'u(k-3)', 'u(k-4)', 'u(k-5)');
	trn_data = data(  1:145, :);
	chk_data = data(146:290, :);
	seqsrch(2, trn_data, chk_data, input_name, 3);
	return;

	% MPG prediction
	[data, input_name] = loadgas;
	trn_data = data(1:2:size(data, 1), :);
	chk_data = data(2:2:size(data, 1), :);
	seqsrch(4, trn_data, chk_data, input_name);
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

anfis_n = (2*all_in_n-in_n+1)*in_n/2;
index = zeros(anfis_n, in_n);

all_input_index = zeros(anfis_n, in_n);
all_trn_error = zeros(anfis_n, 1);
all_chk_error = zeros(anfis_n, 1);

% ====== Train ANFIS with different input variables
input_index = [];
trn_error = realmax*ones(1, all_in_n);
chk_error = realmax*ones(1, all_in_n);
model = 1;
for i=1:in_n,
  fprintf('\nSelecting input %d ...\n', i);
  for j=1:size(trn_data,2)-1,
    if isempty(input_index) | isempty(find(input_index==j)),
      current_input_index = [input_index, j];
      this_trn_data = trn_data(:, [current_input_index, all_in_n+1]);
      this_chk_data = chk_data(:, [current_input_index, all_in_n+1]);
      in_fismat = genfis1(this_trn_data, mf_n, mf_type);
      [trn_out_fismat t_err step_size chk_out_fismat c_err] = ...
	anfis(this_trn_data, in_fismat, ...
	[epoch_n nan ss ss_dec_rate ss_inc_rate], ...
	[0 0 0 0], this_chk_data, 1);
      trn_error(j) = min(t_err);
      chk_error(j) = min(c_err);
      fprintf('ANFIS model %d:', model);
      for k = 1:length(current_input_index),
        fprintf(' %s', deblank(input_name(current_input_index(k), :)));
      end
      fprintf(' --> trn=%.4f,', trn_error(j));
      fprintf(' chk=%.4f', chk_error(j));
      fprintf('\n');
      all_input_index(model,1:length(current_input_index)) = current_input_index;
      all_trn_error(model, 1) = trn_error(j);
      all_chk_error(model, 1) = chk_error(j);
      model = model+1;
    end
  end
  [a,b] = min(trn_error);
  input_index = [input_index, b];
  input_index = sort(input_index);
  fprintf('Currently selected inputs:');
  for p = 1:length(input_index),
    fprintf(' %s', deblank(input_name(input_index(p), :)));
  end
  fprintf('\n');
end

% ====== Generate input_index for further training, if necessary.
[a, b] = min(all_trn_error);
input_index = all_input_index(b, :);
input_index(find(input_index==0))=[];
input_index = sort(input_index);

elapsed_time = etime(clock, t0);

% ====== Display training and checking errors
figTitle = ['Sequential ANFIS Input Selection: Select ', num2str(in_n), ...
	' inputs from ', num2str(all_in_n), ' candidates'];

figH = findobj(0, 'name', figTitle);
if isempty(figH),
	figH = figure('Name', figTitle, 'NumberTitle', 'off');
else
	set(0, 'currentfig', figH);
end

[a, b] = sort(all_trn_error);
all_trn_error = all_trn_error(flipud(b));
all_chk_error = all_chk_error(flipud(b));
all_input_index = all_input_index(flipud(b), :);

x = (1:anfis_n)';
subplot(211);
plot(x, all_trn_error, '-', x, all_chk_error, '-', ...
     x, all_trn_error, 'o', x, all_chk_error, '*');
tmp = x(:, ones(1, 3))';
X = tmp(:);
tmp = [zeros(anfis_n, 1) max(all_trn_error, all_chk_error) nan*ones(anfis_n, 1)]';
Y = tmp(:);
hold on; plot(X, Y, 'g'); hold off;
axis([1 anfis_n -inf inf]);
set(gca, 'xticklabel', []);

% ====== Add text of input variables
for k = 1:anfis_n,
	index = all_input_index(k, :);
	index(find(index==0))=[];
	leng = length(index);
	input_string = [];
	for l=1:leng,
		input_string = [input_string, input_name(index(l), :), ' '];
	end
	text(x(k), 0, input_string);
end
h = findobj(gcf, 'type', 'text');
set(h, 'rot', 90, 'fontsize', 11, 'hori', 'right');
drawnow
title('Training (Circles) and Checking (Asterisks) Errors');
ylabel('RMSE');
