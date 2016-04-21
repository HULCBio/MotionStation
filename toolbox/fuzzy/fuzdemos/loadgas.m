function [data, input_name] = loadgas
%LOADGAS Load data file for automobile MPG (miles per gallon) prediction
% Copyright 1994-2002 The MathWorks, Inc. 
% $Revision: 1.8 $

%	Roger Jang, August 1997

% ====== Get data from original data file
data_file = 'auto-gas.dat';
%fprintf('Getting data from file ''%s''...\n', data_file);
pause(0.1);
fid = fopen(data_file);

raw_data = zeros(500, 8);
i = 1;
while 1
	line = fgetl(fid);
	if ~isstr(line), break, end
	if isempty(find(line=='?')), % get rid of data with missing value
		raw_data(i, :) = sscanf(line, '%f')';
		i = i+1;
	end
end
fclose(fid);
raw_data(i:500, :) = [];

% Rearrange the data so that inputs come first
data = [raw_data(:, 2:7) raw_data(:, 1)];

% ====== Get variable names
%   1. mpg:           continuous
%   2. cylinders:     multi-valued discrete
%   3. displacement:  continuous
%   4. horsepower:    continuous
%   5. weight:        continuous
%   6. acceleration:  continuous
%   7. model year:    multi-valued discrete
%   8. origin:        multi-valued discrete
%   9. car name:      string (unique for each instance)

input_name = ...
	str2mat('Cylinder','Disp','Power','Weight','Acceler','Year','MPG');

% ====== Do linear regression
%trn_data = data(1:2:end, :);
%chk_data = data(2:2:end, :);
%fprintf('Doing linear regression...\n'); 
%fprintf('Linear regression with %d linear parameters:\n', size(data, 2)); 
%A_trn = [trn_data(:, 1:size(data,2)-1) ones(size(trn_data,1), 1)]; 
%B_trn = trn_data(:, size(data,2));
%coef = A_trn\B_trn;
%trn_error = norm(A_trn*coef-B_trn)/sqrt(size(trn_data,1));
%
%A_chk = [chk_data(:, 1:size(data,2)-1) ones(size(chk_data,1), 1)]; 
%B_chk = chk_data(:, size(data,2));
%chk_error = norm(A_chk*coef-B_chk)/sqrt(size(chk_data,1));
%
%fprintf('\tRMSE for training data: %g\n', trn_error); 
%fprintf('\tRMSE for checking data: %g\n', chk_error); 
