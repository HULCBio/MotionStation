function [y,e,S] = adaptrls(x,d,S)
%ADAPTRLS  Recursive least-squares (RLS) FIR adaptive filter.
%   Y = ADAPTRLS(X,D,S) applies an FIR RLS adaptive filter to the data vector X
%   and the desired signal D.  The filtered data is returned in Y.  S is a
%   structure that contains the RLS adaptive filter information:
%
%   S.coeffs  - RLS adaptive filter coefficients. 
%               Should be initialized with the initial values for the
%               FIR filter coefficients. Updated coefficients are returned if S
%               is an output argument.
%   S.invcov  - The inverse of the input covariance matrix. 
%               Should be initialized with the initial input covariance
%               matrix inverse. Updated matrix is returned if S is an output
%               argument and the 'DIRECT' algorithm is used.
%   S.lambda  - The forgetting factor. 
%   S.states  - States of the FIR filter. Optional field.
%               If omitted, Defaults to a zero vector of length equal to the
%               filter order.     
%   S.gain    - The RLS gain factor. Optional field.  It is computed for
%               each iteration. Can be used as read-only.
%               
%   S.iter    - Total number of iterations in adaptive filter run. Optional field.
%               Can be used as read-only.
%
%   S.alg     - Algorithm to use. Optional field. Can be one of 'DIRECT' for the
%               conventional RLS algorithm or 'SQRT' for the more stable square
%               root (QR) method.
%
%   [Y,E]   = ADAPTRLS(...) returns the prediction error E.
%
%   [Y,E,S] = ADAPTRLS(...) returns the updated structure S.
%
%   In an application where the intermediate states are important, the function
%   can be called in a 'sample by sample mode' using a for loop.
%
%   for N = 1:length(X)
%       [Y(N),E(N),S] = ADAPTRLS(X(N),D(N),S);
%       % States (The fields of S) here may be modified here. 
%   end
%
%   In lieu of assigning the strucure fields manually, the INITRLS function can be 
%   called to populate the structure S. 
%
%   EXAMPLE: System Identification for a 32nd length FIR filter (500 iterations).
%      x  = 0.1*randn(1,500); % Input to the filter
%      b  = fir1(31,0.5);     % FIR system to tbe identified
%      d  = filter(b,1,x);    % Desired signal
%      w0 = zeros(1,32);      % Initial filter coefficients
%      P0 = 5*eye(32);        % Initial input correlation matrix inverse
%      lam = 1;               % Exponential memory weighting factor
%      S = initrls(w0,P0,lam);
%      [y,e,S] = adaptrls(x,d,S);
%      stem([b.',S.coeffs.']);
%      legend('Actual','Estimated');
%      title('System Identification of an FIR filter via RLS');grid on;
%
%   See also INITRLS, ADAPTNLMS, ADAPTLMS, and ADAPTKALMAN.

%   References: 
%     [1] S. Haykin, "Adaptive Filter Theory", 3rd Edition,
%         Prentice Hall, N.J., 1996.
%     [2] A. H. Sayed and T. Kailath, "A state-space approach to RLS
%         adaptive filtering". IEEE Signal Processing Magazine, 
%         July 1994. pp. 18-60.  
%
%   Author(s): A. Ramasubramanian
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/11/21 16:14:27 $

warning(generatemsgid('obsolete'), ...
        ['ADAPTRLS is obsolete and will be removed in future versions of \n',...
            'Filter Design Toolbox. Type "help adaptfilt/rls" and "help adaptfilt/filter"\n',...
            'for more information on using the new adaptive filters.\n']);


if ~isfield(S,'gain') | isempty(S.gain),
	[S,error_msg,warn_msg] = parse_inputs(x,d,S);
	error(error_msg);warning(warn_msg);
end

% Call adaptive FIR filter with apriori coefficient update
[y,e,S] = apadaptfirfilt(x,d,S,@updaterls);


%--------------------------------------------------------------------------
function [S,error_msg,warn_msg] = parse_inputs(x,d,S)

% Assign default error and warning messages.
error_msg = ''; warn_msg = ''; 

if ~isequal(length(x),length(d))
    error_msg = 'Input and desired signal vectors should be of same length.';
    return;
end



% Check if coeffs are initialized.
if ~isfield(S,'coeffs')
	error_msg = ['Filter coefficients should be initialized to a ', ...
			'vector of length equal to the filter order.'];
	return; 
end

% Check if FIR filter initial conditions are specified.
if ~isfield(S,'states')
	S.states = zeros(length(S.coeffs)-1,1);
end
% Make sure that FIR filter initial conditions are of correct length.
if ~isequal(length(S.states),length(S.coeffs)-1),
	error_msg = ['FIR initial states should be of length equal to ', ... 
			'the filter order.'];
	return;     
end

% Check if the input covariance matrix inverse is specified.
if ~isfield(S,'invcov')
	error_msg = 'Initial error covariance matrix is not specified.';
	return;
end
% Make sure that the input covariance matrix inverse is of right order.
[M,N] = size(S.invcov);
if ~isequal(M,N,length(S.coeffs))
	error_msg = sprintf(['The input covariance matrix inverse must be ',...
			'square \nwith each dimension equal to the filter order.']);
	return;        
end
% Check if specified input covariance matrix inverse is hermitian symmeteric.
if ~isequal(S.invcov,S.invcov')
	warn_msg = sprintf(['Initial input covariance matrix inverse is not ',...
			'symmeteric: \nErratic behavior might result.']);
end

% Check if the exponential weighting factor is specified.
if ~isfield(S,'lambda')
	error_msg = 'Exponential weighting factor is not specified.';
	return;
end
% Check if lambda is in the right range.
if (S.lambda>1)|(S.lambda<=0)
	warn_msg = sprintf(['Exponential weigting factor is not in range ',...
			'0 < lambda <= 1: \n',...
			'Erratic behavior might result.']);
end

% Complete structure assignment.
S.iter = 0;  % Initialize iteration count.
S.gain = []; % Will be assigned during the first iteration

% Check for the algorithm to use
if isfield(S,'alg'),
	algOpts = {'direct','sqrt'};
	indx = strmatch(lower(S.alg),algOpts);
	if ~isempty(indx),
		S.alg = algOpts{indx};
	else,
		error_msg = 'Unrecognized algorithm specified.';
		return
	end
else
	S.alg = 'direct';
end

% [EOF] 
