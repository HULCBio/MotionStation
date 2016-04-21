function [y,e,S] = adaptnlms(x,d,S)
%ADAPTNLMS Normalized least mean squared (LMS) FIR adaptive filter.
%   Y = ADAPTNLMS(X,D,S) applies a normalized FIR LMS adaptive filter
%   to the data vector X and the desired signal D. The filtered data is
%   returned in Y. S is a structure that contains the adaptive filter
%   information:
%
%   S.coeffs      - FIR filter coefficients.  Should be initialized with
%                   the initial coefficients.  Updated coefficients are
%                   returned if S is an output argument.
%   S.step        - LMS step size (factor of 2 included). 
%   S.states      - States of the FIR filter. Optional field.
%                   If omitted, Defaults to a zero vector of length equal 
%                   to the filter order.
%   S.leakage     - LMS leakage parameter. Optional field. Allows for the
%                   implementation of a leaky LMS algorithm.
%                   Defaults to one if omitted (no leakage).
%   S.offset      - Specifies an optional offset for the normalization term.
%                   This is useful to avoid divide by zero (or very small
%                   numbers) if the square of input data norm becomes very
%                   small. If omitted, it defaults to zero.
%   S.iter        - Total number of iterations in adaptive filter run.
%                   Optional field. Can be used as read-only.
%
%   [Y,E]   = ADAPTNLMS(...) also returns the prediction error E.
%
%   [Y,E,S] = ADAPTNLMS(...) returns the updated structure S.
%
%   ADAPTNLMS can be called for a block of data, when X and D are vectors,
%   or in a 'sample by sample mode' using a for loop:
%
%   for N = 1:length(X)
%       [Y(N),E(N),S] = ADAPTNLMS(X(N),D(N),S);
%       % The fields of S may be modified here. 
%   end
% 
%   In lieu of assigning the structure fields manually, the INITNLMS function can be 
%   called to populate the structure S. 
%
%   EXAMPLE: System Identification of a 31-order FIR filter (500 iterations).
%      x  = 0.1*randn(1,500); % Input to the filter
%      b  = fir1(31,0.5);     % FIR system to be identified
%      d  = filter(b,1,x);    % Desired signal
%      w0 = zeros(1,32);      % Initial filter coefficients
%      mu = 0.8;              % LMS step size
%      S = initnlms(w0,mu);
%      [y,e,S] = adaptnlms(x,d,S);
%      stem([b.',S.coeffs.']);
%      legend('Actual','Estimated');
%      title('System Identification of an FIR filter');grid on;
%
%   See also INITNLMS, ADAPTLMS, ADAPTSE, ADAPTSD, ADAPTSS,
%            ADAPTRLS, and ADAPTKALMAN.

%   References: 
%     [1] S. Haykin, "Adaptive Filter Theory", 3rd Edition,
%         Prentice Hall, N.J., 1996.
%     [2] A. H. Sayed and T. Kailath, "A state-space approach to RLS
%         adaptive filtering". IEEE Signal Processing Magazine, 
%         July 1994. pp. 18-60.  
%
%   Author(s): A. Ramasubramanian
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/11/21 16:14:29 $

warning(generatemsgid('obsolete'), ...
        ['ADAPTNLMS is obsolete and will be removed in future versions of \n',...
            'Filter Design Toolbox. Type "help adaptfilt/nlms" and "help adaptfilt/filter"\n',...
            'for more information on using the new adaptive filters.\n']);


if ~isfield(S,'iter'),
	[S,error_msg,warn_msg] = parse_lms_inputs(x,d,S);
	error(error_msg);warning(warn_msg);
end

% Call adaptive FIR filter
[y,e,S] = adaptfirfilt(x,d,S,@updatenlms);


% [EOF] 
