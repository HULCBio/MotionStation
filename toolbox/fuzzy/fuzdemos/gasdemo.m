%% Car mileage prediction with ANFIS
% This slide show addresses the use of ANFIS function in the Fuzzy Logic
% Toolbox for predicting the MPG (miles per gallon) of a given automobile.
%
% Copyright 1994-2002 The MathWorks, Inc. 
% $Revision: 1.9 $

%%
% Automobile MPG (miles per gallon)  prediction is a typical nonlinear
% regression problem, in which several attributes of an automobile's
% profile information are used to predict another continuous attribute,
% that is, the fuel consumption in MPG. The training data is available from
% the UCI (Univ. of California at Irvine) Machine Learning Repository
% (http://www.ics.uci.edu/~mlearn/MLRepository.html). It contains data
% collected from automobiles of various manufactures and models, as shown
% in the next slide.
%
% The table shown above is several tuples from the MPG data set.  The six
% input attributes are no. of cylinders, displacement, horsepower, weight,
% acceleration, and model year; the output variable to be predicted is the
% fuel consumption in MPG. (The automobile's manufacturers and models in
% the first column of the table are not used for prediction.  The data set
% is obtained from the original data file 'auto-gas.dat'. Then we partition
% the data set into a training set (odd-indexed tuples) and a checking set
% (even-indexed tuples), and use the function 'exhsrch' to find the input
% attributes that have better prediction power for ANFIS modeling.

a=imread('gasdata.jpg', 'jpg');
image(a); colormap(gray); axis image;
axis off
[data, input_name] = loadgas;
trn_data = data(1:2:end, :);
chk_data = data(2:2:end, :);

%%
% To select the best input attribute, 'exhsrch' constructs six ANFIS, each
% with a single input attribute. Here the result
% after executing exhsrch(1, trn_data, chk_data, input_name). Obviously,
% 'Weight' is the most influential input attribute and 'Disp' is the second
% one, etc.  The training and checking errors are comparable in size, which
% implies that there is no overfitting and we can select more input
% variables. Intuitively, we can simply select 'Weight' and 'Disp'
% directly.  However, this will not necessarily lead to a two-ANFIS model
% with the minimal training error.  To verify this, we can issue the
% command exhsrch(2, trn_data, chk_data, input_name) to select the best two
% inputs from all possible combinations.

exhsrch(1, trn_data, chk_data, input_name);
win1 = gcf;

%%
% Demonstrate the result of selecting two inputs. 'Weight' and 'Year' are
% selected as the best two input variables, which is quite reasonable.  The
% training and checking errors are getting distinguished, indicating the
% outset of overfitting.  As a comparison, let us use exhsrch to select
% three inputs

input_index = exhsrch(2, trn_data, chk_data, input_name);
new_trn_data = trn_data(:, [input_index, size(trn_data,2)]);
new_chk_data = chk_data(:, [input_index, size(chk_data,2)]);
win2 = gcf;

%%
% The popped figure demonstrates the result of selecting three inputs, in
% which 'Weight', 'Year', and 'Acceler' are selected as the best three
% input variables.  However, the minimal training (and checking) error do
% not reduce significantly from that of the best 2-input model, which
% indicates that the newly added attribute 'Acceler' does not improve the
% prediction too much.  For better generalization, we always prefer a model
% with a simple structure. Therefore we will stick to the two-input ANFIS
% for further exploration

exhsrch(3, trn_data, chk_data, input_name);
win3 = gcf;

%%
% The input-output surface of the best two-input ANFIS model for MPG
% prediction is shown above. It is a nonlinear and monotonic surface, in
% which the predicted MPG increases with the increase in 'Weight' and
% decrease in 'Year'. The training RMSE (root mean squared error) is 2.766;
% the checking RMSE is 2.995. In comparison, a simple linear regression
% using all input candidates results in a training RMSE of 3.452, and a
% checking RMSE of 3.444.

if ishandle(win1), delete(win1); end
if ishandle(win2), delete(win2); end
if ishandle(win3), delete(win3); end

in_fis=genfis1(new_trn_data);
mf_n = 2;
mf_type = 'gbellmf';
epoch_n = 1;
ss = 0.01;
ss_dec_rate = 0.5;
ss_inc_rate = 1.5;
in_fismat = genfis1(new_trn_data, mf_n, mf_type);
[trn_out_fismat trn_error step_size chk_out_fismat chk_error] = anfis(new_trn_data, in_fismat, [epoch_n nan ss ss_dec_rate ss_inc_rate], nan, new_chk_data, 1);
for i=1:length(input_index),
    chk_out_fismat = setfis(chk_out_fismat, 'input', i, 'name', deblank(input_name(input_index(i), :)));
end
chk_out_fismat = setfis(chk_out_fismat, 'output', 1, 'name', deblank(input_name(size(input_name, 1), :)));
gensurf(chk_out_fismat); colormap('default');
set(gca, 'box', 'on');
view(-22, 36);
fprintf('\nLinear regression with parameters:\n');
param= size(trn_data,2)
A_trn = [trn_data(:, 1:size(data,2)-1) ones(size(trn_data,1), 1)];
B_trn = trn_data(:, size(data,2));
coef = A_trn\B_trn;
trn_error = norm(A_trn*coef-B_trn)/sqrt(size(trn_data,1));
A_chk = [chk_data(:, 1:size(data,2)-1) ones(size(chk_data,1), 1)];
B_chk = chk_data(:, size(data,2));
chk_error = norm(A_chk*coef-B_chk)/sqrt(size(chk_data,1));
fprintf('\nRMSE for training data: ');
RMSE=trn_error
fprintf('\nRMSE for checking data: ');
RMSE = chk_error

%%
% The function exhsrch only trains each ANFIS for a single epoch in order
% to be able to find the right inputs shortly.  Now that the inputs are
% fixed, we can spend more time on ANFIS training.  The above plot is the
% error curves for 100 epochs of ANFIS training.  The green curve is the
% training errors; the red one is the checking errors. The minimal checking
% error occurs at about epoch 45, which is indicated by a circle.  Notice
% that the checking error curve is going up after 50 epochs, indicating
% that further training overfits the data and produce worse generalization

watchon;
epoch_n = 100;
[trn_out_fismat trn_error step_size chk_out_fismat chk_error] = anfis(new_trn_data, in_fismat, [epoch_n nan ss ss_dec_rate ss_inc_rate], nan, new_chk_data, 1);
[a, b] = min(chk_error);
plot(1:epoch_n, trn_error, 'g-', 1:epoch_n, chk_error, 'r-', b, a, 'ko');
axis([-inf inf -inf inf]);
title('Training (green) and checking (red) error curve');
xlabel('Epoch numbers');
ylabel('RMS errors');
watchoff;

%%
% The snapshot of the two-input ANFIS at the minimal checking error has the
% above input-output surface. Both the training and checking errors are
% lower than before, but we can see some spurious effects at the far-end
% corner of the surface.  The elevated corner says that the heavier an
% automobile is, the more gas-efficient it will be. This is totally
% counter-intuitive, and it is a direct result from lack of data.

gensurf(chk_out_fismat);
set(gca, 'box', 'on');
view(-22, 36);

%%
% This plot shows the data distribution. The lack of training data at the
% upper right corner causes the spurious ANFIS surface mentioned earlier.
% Therefore the prediction by ANFIS should always be interpreted with the
% data distribution in mind.

plot(new_trn_data(:,1), new_trn_data(:, 2), 'bo', new_chk_data(:,1), new_chk_data(:, 2), 'rx');
axis([-inf inf -inf inf]);
xlabel(deblank(input_name(input_index(1), :)));
ylabel(deblank(input_name(input_index(2), :)));
title('Training (o) and checking (x) data');



