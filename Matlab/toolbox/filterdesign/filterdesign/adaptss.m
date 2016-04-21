function [y,e,S] = adaptss(x,d,S)
%ADAPTSS Sign-sign FIR adaptive filter.
%   Y = ADAPTSS(X,D,S) applies a sign-sign FIR adaptive filter
%   to the data vector X and the desired signal D. Note that for this
%   algorithm both X and D must be real. The filtered data is
%   returned in Y. S is a structure that contains the adaptive filter
%   information:
%
%   S.coeffs      - FIR filter coefficients.  Should be initialized with
%                   the initial coefficients.  Updated coefficients are
%                   returned if S is an output argument.
%   S.step        - Step size (factor of 2 included). 
%   S.states      - States of the FIR filter. Optional field.
%                   If omitted, Defaults to a zero vector of length equal 
%                   to the filter order.
%   S.leakage     - LMS leakage parameter. Optional field. Allows for the
%                   implementation of a leaky sign algorithm.
%                   Defaults to one if omitted (no leakage).
%   S.iter        - Total number of iterations in adaptive filter run.
%                   Optional field. Can be used as read-only.
%
%   [Y,E]   = ADAPTSS(...) also returns the prediction error E.
%
%   [Y,E,S] = ADAPTSS(...) returns the updated structure S.
%
%   ADAPTSS can be called for a block of data, when X and D are vectors,
%   or in a 'sample by sample mode' using a for loop:
%
%   for N = 1:length(X)
%       [Y(N),E(N),S] = ADAPTSS(X(N),D(N),S);
%       % The fields of S may be modified here. 
%   end
% 
%   In lieu of assigning the structure fields manually, the INITSS function can be 
%   called to populate the structure S. 
%
%   EXAMPLE: Adaptive linear prediction with two different step sizes
%     u = randn(1,2000); % Input
%     y1 = filter(1,[1,-.5],u(1:1000)); y2 = filter(1,[1,-.7],u(1001:2000)); 
%     y = [y1,y2];
%     mu1 = 0.005; mu2 = 0.015; w0 = zeros(1,2);
%     S1 = initss(w0,mu1); S2 = initss(w0,mu2);
%     for n = 1:length(y),
%         [z1(n),e1(n),S1] = adaptss(u(n),y(n),S1);...
%         [z2(n),e2(n),S2] = adaptss(u(n),y(n),S2);
%         coeffs1(n,:) = S1.coeffs; coeffs2(n,:) = S2.coeffs;
%     end
%     plot([coeffs1(:,2),coeffs2(:,2),[.5*ones(1000,1);.7*ones(1000,1)]])
%     legend('Actual coefficient value, Mu = 0.005',...
%         'Actual coefficient value, Mu = 0.015','Optimal value')
%     xlabel('Sample index n'),ylabel('Coefficient value');
%
%   See also INITSS, ADAPTSE, ADAPTSD, ADAPTLMS, ADAPTNLMS, and ADAPTRLS.

%   References: 
%     [1] M. Hayes, "Statistical Digital Signal Processing and Modeling",
%         John Wiley and Sons, N.Y., 1996.
%     [2] P. Diniz, "Adaptive Filtering. Algorithms and Practical Implementation".
%         Kluwer Academic Publishers, Boston, 1997.
%
%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/11/21 16:14:36 $

warning(generatemsgid('obsolete'), ...
        ['ADAPTSS is obsolete and will be removed in future versions of \n',...
            'Filter Design Toolbox. Type "help adaptfilt/ss" and "help adaptfilt/filter"\n',...
            'for more information on using the new adaptive filters.\n']);


if ~isreal(x) | ~isreal(d),
	error('This algorithm can only be used with real data.');
end

if ~isfield(S,'iter'),
	[S,error_msg,warn_msg] = parse_lms_inputs(x,d,S);
	error(error_msg);warning(warn_msg);
end

% Call adaptive FIR filter
[y,e,S] = adaptfirfilt(x,d,S,@updatess);


% [EOF] 
