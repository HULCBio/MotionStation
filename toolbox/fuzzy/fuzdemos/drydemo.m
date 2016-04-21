%% Nonlinear system identification
% This demo addresses the use of ANFIS function in the Fuzzy Logic
% Toolbox for nonlinear dynamical system identification. This demo also
% requires the System Identification Toolbox, as a comparison is made
% between a nonlinear ANFIS and a linear ARX model.
%
% Copyright 1994-2002 The MathWorks, Inc. 
% $Revision: 1.9 $

% Exit if the IDENT toolbox is not on the path
if exist('arx.m','file') == 0
  errordlg('DRYDEMO requires the System Identification Toolbox.');
  return;
end


%%
% The data set for ANFIS and ARX modeling was obtained from a laboratory
% device called Feedback's Process Trainer PT 326, as described in Chapter
% 17 of Prof. Lennart Ljung's book "System Identification, Theory for the
% User", Prentice-Hall, 1987. The device's function is like a hair dryer:
% air is fanned through a tube and heated at the inlet. The air temperature
% is measure by a thermocouple at the outlet. The input u(k) is the voltage
% over a mesh of resistor wires to heat incoming air; the output y(k) is
% the outlet air temperature. Here is a the system model

a=imread('dryblock.jpg', 'jpg');
image(a); 
axis image;
axis off;

%%
% Here are the results of the test.

load dryer2;
data_n = length(y2);
output = y2;
input = [[0; y2(1:data_n-1)] ...
        [0; 0; y2(1:data_n-2)] ...
        [0; 0; 0; y2(1:data_n-3)] ...
        [0; 0; 0; 0; y2(1:data_n-4)] ...
        [0; u2(1:data_n-1)] ...
        [0; 0; u2(1:data_n-2)] ...
        [0; 0; 0; u2(1:data_n-3)] ...
        [0; 0; 0; 0; u2(1:data_n-4)] ...
        [0; 0; 0; 0; 0; u2(1:data_n-5)] ...
        [0; 0; 0; 0; 0; 0; u2(1:data_n-6)]];
data = [input output];
data(1:6, :) = [];
input_name = str2mat('y(k-1)','y(k-2)','y(k-3)','y(k-4)','u(k-1)','u(k-2)','u(k-3)','u(k-4)','u(k-5)','u(k-6)');
trn_data_n = 300;
index = 1:100;
subplot(2,1,1);
plot(index, y2(index), '-', index, y2(index), 'o');
ylabel('y(k)');
subplot(2,1,2);
plot(index, u2(index), '-', index, u2(index), 'o');
ylabel('u(k)');

%%
% The data points was collected at a sampling time of 0.08 second. One
% thousand input-output data points were collected from the process as the
% input u(k) was chosen to be a binary random signal shifting between 3.41
% and 6.41 V. The probability of shifting the input at each sample was 0.2.
% The data set is available from the System Identification Toolbox; and the
% above plots show the output temperature y(k) and input voltage u(t) for
% the first 100 time steps.

%%
% A conventional method is to remove the means from the data and assume a
% linear model of the form:
%
% y(k)+a1*y(k-1)+...+am*y(k-m)=b1*u(k-d)+...+bn*u(k-d-n+1)
%
% where ai (i = 1 to m) and bj (j = 1 to n) are linear parameters to be
% determined by least-squares methods. This structure is called the ARX
% model and it is exactly specified by three integers [m, n, d]. To find an
% ARX model for the dryer device, the data set was divided into a training
% (k = 1 to 300) and a checking (k = 301 to 600) set.  An exhaustive search
% was performed to find the best combination of [m, n, d], where each of
% the integer is allowed to changed from 1 to 10 independently. The best
% ARX model thus found is specified by [m, n, d] = [5, 10, 2], with a
% training RMSE of 0.1122 and a checking RMSE of 0.0749. The above figure
% demonstrates the fitting results of the best ARX model.

trn_data_n = 300;
total_data_n = 600;
z = [y2 u2];
z = dtrend(z);
ave = mean(y2);
ze = z(1:trn_data_n, :);
zv = z(trn_data_n+1:total_data_n, :);
T = 0.08;

% Run through all different models
V = arxstruc(ze, zv, struc(1:10, 1:10, 1:10));
% Find the best model
nn = selstruc(V, 0);
% Time domain plot
th = arx(ze, nn);
th = sett(th, 0.08);
u = z(:, 2);
y = z(:, 1)+ave;
yp = idsim(u, th)+ave;

xlbl = 'Time Steps';

subplot(2,1,1); 
index = 1:trn_data_n;
plot(index, y(index), index, yp(index), '.');
rmse = norm(y(index)-yp(index))/sqrt(length(index));
title(['(a) Training Data (Solid Line) and ARX Prediction (Dots) with RMSE = ' num2str(rmse)]);
disp(['[na nb d] = ' num2str(nn)]);
xlabel(xlbl);

subplot(2,1,2); 
index = (trn_data_n+1):(total_data_n);
plot(index, y(index), index, yp(index), '.');
rmse = norm(y(index)-yp(index))/sqrt(length(index));
title(['(b) Checking Data (Solid Line) and ARX Prediction (Dots) with RMSE = ' num2str(rmse)]);
xlabel(xlbl);

%%
% The ARX model is inherently linear and the most significant advantage is
% that we can perform model structure and parameter identification rapidly.
% The performance in the above plots appear to be satisfactory. However, if
% a better performance level is desired, we might want to resort to a
% nonlinear model.  In particular, we are going to use a neuro-fuzzy
% modeling approach, ANFIS, to see if we can push the performance level by
% using a fuzzy inference system.

%%
% To use ANFIS for system identification, the first thing we need to do is
% input selection. That is, to determine which variables should be the
% input arguments to an ANFIS model.  For simplicity, we suppose that there
% are 10 input candidates (y(k-1), y(k-2), y(k-3), y(k-4), u(k-1), u(k-2),
% u(k-3), u(k-4), u(k-5), u(k-6)), and the output to be predicted is y(k).
% A heuristic approach to input selection is called sequential forward
% search, in which each input is selected sequentially to optimize the
% total squared error. This can be done by the function seqsrch; the result
% is shown in the above plot, where 3 inputs (y(k-1), u(k-3), and u(k-4))
% are selected with a training RMSE of 0.0609 and checking RMSE of 0.0604.

trn_data_n = 300;
trn_data = data(1:trn_data_n, :);
chk_data = data(trn_data_n+1:trn_data_n+300, :);
[input_index, elapsed_time]=seqsrch(3, trn_data, chk_data, input_name);
fprintf('\nElapsed time = %f\n', elapsed_time);
winH1 = gcf;

%%
% For input selection, another more computation intensive approach is to do
% an exhaustive search on all possible combinations of the input
% candidates. The function that performs exhaustive search is exhsrch,
% which selects 3 inputs from 10 candidates.  However, exhsrch usually
% involves a significant amount of computation if all combinations are
% tried.  For instance, if 3 is selected out of 10, the total number of
% ANFIS models is C(10, 3) = 120.
%
% Fortunately, for dynamical system identification, we do know that the inputs should not come from either of the following two sets of input candidates exclusively:
%
% Y = {y(k-1), y(k-2), y(k-3), y(k-4)}
%
% U = {u(k-1), u(k-2), u(k-3), u(k-4), u(k-5), u(k-6)}
%
% A reasonable guess would be to take two inputs from Y and one from U to
% form the inputs to ANFIS; the total number of ANFIS models is then
% C(4,2)*6=36, which is much less.  The above plot shows that the selected
% inputs are y(k-1), y(k-2) and u(k-3), with a training RMSE of 0.0474 and
% checking RMSE of 0.0485, which are better than ARX models and ANFIS via
% sequential forward search.

group1 = [1 2 3 4];	% y(k-1), y(k-2), y(k-3), y(k-4)
group2 = [1 2 3 4];	% y(k-1), y(k-2), y(k-3), y(k-4)
group3 = [5 6 7 8 9 10];	% u(k-1) through y(k-6)

anfis_n = 6*length(group3);
index = zeros(anfis_n, 3);
trn_error = zeros(anfis_n, 1);
chk_error = zeros(anfis_n, 1);
% ======= Training options 
mf_n = 2;
mf_type = 'gbellmf';
epoch_n = 1;
ss = 0.1;
ss_dec_rate = 0.5;
ss_inc_rate = 1.5;
% ====== Train ANFIS with different input variables
fprintf('\nTrain %d ANFIS models, each with 3 inputs selected from 10 candidates...\n\n',...
    anfis_n);
model = 1;
for i=1:length(group1),
    for j=i+1:length(group2),
        for k=1:length(group3),
            in1 = deblank(input_name(group1(i), :));
            in2 = deblank(input_name(group2(j), :));
            in3 = deblank(input_name(group3(k), :));
            index(model, :) = [group1(i) group2(j) group3(k)];
            trn_data = data(1:trn_data_n, [group1(i) group2(j) group3(k) size(data,2)]);
            chk_data = data(trn_data_n+1:trn_data_n+300, [group1(i) group2(j) group3(k) size(data,2)]);
            in_fismat = genfis1(trn_data, mf_n, mf_type);
            [trn_out_fismat t_err step_size chk_out_fismat c_err] = ...
                anfis(trn_data, in_fismat, ...
                [epoch_n nan ss ss_dec_rate ss_inc_rate], ...
                [0 0 0 0], chk_data, 1);
            trn_error(model) = min(t_err);
            chk_error(model) = min(c_err);
            fprintf('ANFIS model = %d: %s %s %s', model, in1, in2, in3);
            fprintf(' --> trn=%.4f,', trn_error(model));
            fprintf(' chk=%.4f', chk_error(model));
            fprintf('\n');
            model = model+1;
        end
    end
end

% ====== Reordering according to training error
[a b] = sort(trn_error);
b = flipud(b);		% List according to decreasing trn error
trn_error = trn_error(b);
chk_error = chk_error(b);
index = index(b, :);

% ====== Display training and checking errors
x = (1:anfis_n)';
subplot(2,1,1);
plot(x, trn_error, '-', x, chk_error, '-', ...
    x, trn_error, 'o', x, chk_error, '*');
tmp = x(:, ones(1, 3))';
X = tmp(:);
tmp = [zeros(anfis_n, 1) max(trn_error, chk_error) nan*ones(anfis_n, 1)]';
Y = tmp(:);
hold on; 
plot(X, Y, 'g'); 
hold off;
axis([1 anfis_n -inf inf]);
set(gca, 'xticklabel', []);

% ====== Add text of input variables
for k = 1:anfis_n,
    text(x(k), 0, ...
        [input_name(index(k,1), :) ' ' ...
            input_name(index(k,2), :) ' ' ...
            input_name(index(k,3), :)]);
end
h = findobj(gcf, 'type', 'text');
set(h, 'rot', 90, 'fontsize', 11, 'hori', 'right');
drawnow

% ====== Generate input_index for bjtrain.m
[a b] = min(trn_error);
input_index = index(b,:);
title('Training (Circles) and Checking (Asterisks) Errors');
ylabel('RMSE');

%%
% The popped window shows ANFIS predictions on both training and checking
% data sets.  Obviously the performance is better than those of the ARX
% model.

if ishandle(winH1), delete(winH1); end

ss = 0.01;
ss_dec_rate = 0.5;
ss_inc_rate = 1.5;

trn_data = data(1:trn_data_n, [input_index, size(data,2)]);
chk_data = data(trn_data_n+1:600, [input_index, size(data,2)]);

% generate FIS matrix
in_fismat = genfis1(trn_data);

[trn_out_fismat trn_error step_size chk_out_fismat chk_error] = ...
    anfis(trn_data, in_fismat, [1 nan ss ss_dec_rate ss_inc_rate], ...
    nan, chk_data, 1);

subplot(2,1,1);
index = 1:trn_data_n;
plot(index, y(index), index, yp(index), '.');
rmse = norm(y(index)-yp(index))/sqrt(length(index));
title(['(a) Training Data (Solid Line) and ARX Prediction (Dots) with RMSE = ' num2str(rmse)]);
disp(['[na nb d] = ' num2str(nn)]);
xlabel('Time Steps');
subplot(2,1,2);
index = (trn_data_n+1):(total_data_n);
plot(index, y(index), index, yp(index), '.');
rmse = norm(y(index)-yp(index))/sqrt(length(index));
title(['(b) Checking Data (Solid Line) and ARX Prediction (Dots) with RMSE = ' num2str(rmse)]);
xlabel('Time Steps');

%%
y_hat = evalfis(data(1:600,input_index), chk_out_fismat);

subplot(2,1,1);
index = 1:trn_data_n;
plot(index, data(index, size(data,2)), '-', ...
    index, y_hat(index), '.');
rmse = norm(y_hat(index)-data(index,size(data,2)))/sqrt(length(index));
title(['Training Data (Solid Line) and ANFIS Prediction (Dots) with RMSE = ' num2str(rmse)]);
xlabel('Time Index'); ylabel('');

subplot(2,1,2);
index = trn_data_n+1:600;
plot(index, data(index, size(data,2)), '-', index, y_hat(index), '.');
rmse = norm(y_hat(index)-data(index,size(data,2)))/sqrt(length(index));
title(['Checking Data (Solid Line) and ANFIS Prediction (Dots) with RMSE = ' num2str(rmse)]);
xlabel('Time Index'); ylabel('');

%%
% The above table is a comparison among various modeling approaches. The
% ARX modeling spends the least amount of time to reach the worse
% precision, which the ANFIS modeling via exhaustive search takes the
% largest amount of time to reach the best percision.  In other words, if
% fast modeling is the goal, then ARX is the right choice.  But if
% precision is the utmost concern, then we can go for ANFIS that is
% designed for nonlinear modeling and higher precision.

subplot(1,1,1)
a=imread('drytable.jpg', 'jpg');
image(a); 
axis image;
axis off;