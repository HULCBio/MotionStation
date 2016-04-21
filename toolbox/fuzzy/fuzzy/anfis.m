function [t_fismat, t_error, stepsize, c_fismat, c_error] ...
    = anfis(trn_data, in_fismat, t_opt, d_opt, chk_data, method)
%ANFIS   Adaptive Neuro-Fuzzy training of Sugeno-type FIS.
%   
%   ANFIS uses a hybrid learning algorithm to identify the membership function
%   parameters of single-output, Sugeno type fuzzy inference systems (FIS). A
%   combination of least-squares and backpropagation gradient descent methods
%   are used for training FIS membership function parameters to model a given
%   set of input/output data.
%
%   [FIS,ERROR] = ANFIS(TRNDATA) tunes the FIS parameters using the
%   input/output training data stored in TRNDATA. For an FIS with N inputs,
%   TRNDATA is a matrix with N+1 columns where the first N columns contain data
%   for each FIS input and the last column contains the output data. ERROR is
%   the array of root mean square training errors (difference between the FIS
%   output and the training data output) at each epoch. ANFIS uses GENFIS1 to
%   create a default FIS that is used as the starting point for ANFIS training.
%
%   [FIS,ERROR] = ANFIS(TRNDATA,INITFIS) uses the FIS structure, INITFIS as the 
%   starting point for ANFIS training.
%
%   [FIS,ERROR,STEPSIZE] = ANFIS(TRNDATA,INITFIS,TRNOPT,DISPOPT,[],OPTMETHOD)
%   uses the vector TRNOPT to specify training options:
%       TRNOPT(1): training epoch number                     (default: 10)
%       TRNOPT(2): training error goal                       (default: 0)
%       TRNOPT(3): initial step size                         (default: 0.01)
%       TRNOPT(4): step size decrease rate                   (default: 0.9)
%       TRNOPT(5): step size increase rate                   (default: 1.1)
%   The training process stops whenever the designated epoch number is reached
%   or the training error goal is achieved. STEPSIZE is an array of step sizes.
%   The step size is increased or decreased by multiplying it by the step size
%   increase or decrease rate as specified in the training options. Entering NaN
%   for any option will select the default value.
%
%   Use the DISPOPT vector to specify display options during training. Select 1
%   to display, or 0 to hide information:
%       DISPOPT(1): general ANFIS information                (default: 1)
%       DISPOPT(2): error                                    (default: 1)
%       DISPOPT(3): step size at each parameter update       (default: 1)
%       DISPOPT(4): final results                            (default: 1)
%
%   OPTMETHOD selects the optimization method used in training. Select 1 to use
%   the default hybrid method, which combines least squares estimation with
%   backpropagation. Select 0 to use the backpropagation method.
%
%   [FIS,ERROR,STEPSIZE,CHKFIS,CHKERROR] = ...
%   ANFIS(TRNDATA,INITFIS,TRNOPT,DISPOPT,CHKDATA) uses the checking (validation)
%   data CHKDATA to prevent overfitting of the training data set. CHKDATA has
%   the same format as TRNDATA. Overfitting can be detected when the checking
%   error (difference between the output from CHKFIS and the checking data
%   output) starts increasing while the training error is still decreasing.
%   CHKFIS is the snapshot FIS taken when the checking data error reaches a
%   minimum. CHKERROR is the array of the root mean squared, checking data 
%   errors at each epoch.
%
%   Example
%       x = (0:0.1:10)';
%       y = sin(2*x)./exp(x/5);
%       epoch_n = 20;
%       in_fis  = genfis1([x y],5,'gbellmf');
%       out_fis = anfis([x y],in_fis,epoch_n);
%       plot(x,y,x,evalfis(x,out_fis));
%       legend('Training Data','ANFIS Output');
%
%   See also GENFIS1, ANFISEDIT.

%   Roger Jang, 9-12-94.  Kelly Liu, 10-10-97, N. Hickey 04-16-01
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.31.2.1 $  $Date: 2003/01/07 19:34:35 $

%   References
%   Jang, J.-S. R., Fuzzy Modeling Using Generalized Neural Networks and
%   Kalman Filter Algorithm, Proc. of the Ninth National Conf. on Artificial
%   Intelligence (AAAI-91), pp. 762-767, July 1991.
%   Jang, J.-S. R., ANFIS: Adaptive-Network-based Fuzzy Inference Systems,
%   IEEE Transactions on Systems, Man, and Cybernetics, Vol. 23, No. 3, pp.
%   665-685, May 1993.

if nargin > 6 || nargin < 1,
    error('Too many or too few input arguments!');
end

% Change the following to set default train options.
default_t_opt = [10;    % training epoch number
        0;  % training error goal
        0.01;   % initial step size
        0.9;    % step size decrease rate
        1.1];   % step size increase rate

% Change the following to set default display options.
default_d_opt = [1; % display ANFIS information
        1;  % display error measure
        1;  % display step size
        1]; % display final result
% Change the following to set default MF type and numbers
default_mf_type = 'gbellmf';    % default MF type
default_outmf_type='linear';
default_mf_number = 2;
if nargin <= 5,
    method = 1;
end
if nargin <= 4,
    chk_data = [];
end
if nargin <= 3,
    d_opt = default_d_opt;
end
if nargin <= 2,
    t_opt = default_t_opt;
end
if nargin <= 1,
    in_fismat = default_mf_number;
end

% If fismat, d_opt or t_opt are nan's or []'s, replace them with default settings
if isempty(in_fismat)
   in_fismat = default_mf_number;
elseif ~isstruct(in_fismat) & length(in_fismat) == 1 & isnan(in_fismat),
   in_fismat = default_mf_number;
end 
if isempty(t_opt),
    t_opt = default_t_opt;
elseif length(t_opt) == 1 & isnan(t_opt),
    t_opt = default_t_opt;
end
if isempty(d_opt),
    d_opt = default_d_opt;
elseif length(d_opt) == 1 & isnan(d_opt),
    d_opt = default_d_opt;
end
if isempty(method)
   method = 1;
elseif length(method) == 1 & isnan(method),
   method = 1;
elseif method>1 |method<0
   method =1;
end 
% If d_opt or t_opt is not fully specified, pad it with default values. 
if length(t_opt) < 5,
    tmp = default_t_opt;
    tmp(1:length(t_opt)) = t_opt;
    t_opt = tmp;
end
if length(d_opt) < 5,
    tmp = default_d_opt;
    tmp(1:length(d_opt)) = d_opt;
    d_opt = tmp;
end

% If entries of d_opt or t_opt are nan's, replace them with default settings
nan_index = find(isnan(d_opt)==1);
d_opt(nan_index) = default_d_opt(nan_index);
nan_index = find(isnan(t_opt)==1);
t_opt(nan_index) = default_t_opt(nan_index);

% Generate FIS matrix if necessary
% in_fismat is a single number or a vector 
if class(in_fismat) ~= 'struct',
    in_fismat = genfis1(trn_data, in_fismat, default_mf_type);
end

% More input/output argument checking
if nargin <= 4 & nargout > 3,
    error('Too many output arguments!');
end
if length(t_opt) ~= 5,
    error('Wrong length of t_opt!');
end
if length(d_opt) ~= 4,
    error('Wrong length of d_opt!');
end

% Start the real thing!
if nargout == 0,
    anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data, method);
elseif nargout == 1,
    [t_fismat] = ...
        anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data, method);
elseif nargout == 2,
    [t_fismat, t_error] = ...
        anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data, method);
elseif nargout == 3,
    [t_fismat, t_error, stepsize] = ...
        anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data, method);
elseif nargout == 4,
    [t_fismat, t_error, stepsize, c_fismat] = ...
        anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data, method);
elseif nargout == 5,
    [t_fismat, t_error, stepsize, c_fismat, c_error] = ...
        anfismex(trn_data, in_fismat, t_opt, d_opt, chk_data, method);
else
    error('Too many output arguments!');
end
