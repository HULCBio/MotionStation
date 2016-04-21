function [y,e,S] = adaptlms(x,d,S)
%ADAPTLMS Least mean squared (LMS) FIR adaptive filter.
%   Y = ADAPTLMS(X,D,S) applies an FIR LMS adaptive filter to the data
%   vector X and the desired signal D. The filtered data is returned 
%   in Y. S is a structure that contains the LMS adaptive filter information:
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
%   S.iter        - Total number of iterations in adaptive filter run.
%                   Optional field. Can be used as read-only.
%
%   [Y,E]   = ADAPTLMS(...) also returns the prediction error E.
%
%   [Y,E,S] = ADAPTLMS(...) returns the updated structure S.
%
%   ADAPTLMS can be called for a block of data, when X and D are vectors,
%   or in a 'sample by sample mode' using a for loop:
%
%   for N = 1:length(X)
%       [Y(N),E(N),S] = ADAPTLMS(X(N),D(N),S);
%       % The fields of S may be modified here. 
%   end
% 
%   In lieu of assigning the structure fields manually, the INITLMS function can be 
%   called to populate the structure S. 
%
%   EXAMPLE: System Identification of a 31-order FIR filter (500 iterations).
%      x  = 0.1*randn(1,500); % Input to the filter
%      b  = fir1(31,0.5);     % FIR system to be identified
%      d  = filter(b,1,x);    % Desired signal
%      w0 = zeros(1,32);      % Initial filter coefficients
%      mu = 0.8;              % LMS step size
%      S = initlms(w0,mu);
%      [y,e,S] = adaptlms(x,d,S);
%      stem([b.',S.coeffs.']);
%      legend('Actual','Estimated');
%      title('System Identification of an FIR filter');grid on;
%
%   See also INITLMS, ADAPTNLMS, ADAPTSE, ADAPTSD, ADAPTSS, 
%            ADAPTRLS, and ADAPTKALMAN.

%   References: 
%     [1] S. Haykin, "Adaptive Filter Theory", 3rd Edition,
%         Prentice Hall, N.J., 1996.
%     [2] A. H. Sayed and T. Kailath, "A state-space approach to RLS
%         adaptive filtering". IEEE Signal Processing Magazine, 
%         July 1994. pp. 18-60.  

%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/11/21 16:14:32 $

warning(generatemsgid('obsolete'), ...
        ['ADAPTLMS is obsolete and will be removed in future versions of \n',...
            'Filter Design Toolbox. Type "help adaptfilt/lms" and "help adaptfilt/filter"\n',...
            'for more information on using the new adaptive filters.\n']);
    
if ~isfield(S,'iter'),
	[S,error_msg,warn_msg] = parse_lms_inputs(x,d,S);
	error(error_msg);warning(warn_msg);
end

% Call adaptive FIR filter
[y,e,S] = adaptfirfilt(x,d,S,@updatelms);


% [EOF] 
