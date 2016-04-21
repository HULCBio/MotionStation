function S = initlms(w0,mu,Zi,LF)
%INITLMS Initialize structure for FIR LMS adaptive filter.
%   S = INITLMS(W0,MU) returns the fully populated structure that 
%   must be used when calling ADAPTLMS. W0 is the initial value of the
%   filter coefficients.  Its length should be equal to the filter order
%   plus one.  MU is the LMS step size.
%
%   S = INITLMS(W0,MU,Zi) specifies the filter initial conditions.
%   It can be specified as empty, [], to get the default values, i.e.,
%   a zero vector of length one less than length(w0).
%
%   S = INITLMS(W0,MU,Zi,LF) specifies the leakage factor LF. If specified
%   as empty, it defaults to one. 
%
%   See also ADAPTLMS, INITNLMS, ADAPTNLMS, INITRLS.

%   References: 
%     [1] S. Haykin, "Adaptive Filter Theory", 3rd Edition,
%         Prentice Hall, N.J., 1996.
%
%   Author(s): A. Ramasubramanian
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2002/11/21 16:14:33 $

warning(generatemsgid('obsolete'), ...
        ['INITLMS is obsolete and will be removed in future versions of \n',...
            'Filter Design Toolbox. Type "help adaptfilt/lms" and "help adaptfilt/filter"\n',...
            'for more information on using the new adaptive filters.\n']);

error(nargchk(2,4,nargin));

% Convert w0 to a row vector if not already so.
w0 = w0(:).';

if nargin < 3 | isempty(Zi),
	% Use default
	Zi = zeros(length(w0)-1,1);
end

if ~isequal(length(Zi),length(w0)-1),
	error('The number of initial states should equal the filter order.');
end

% Check if a leakage factor was specified.
if nargin < 4 | isempty(LF),
	LF = 1;
end


% Assign structure fields only after error checking is complete:
S.coeffs  = w0;
S.states  = Zi;
S.step    = mu;
S.leakage = LF;
S.iter    = 0;  % Iteration count.
                     
% [EOF] 
