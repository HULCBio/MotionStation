function S = initnlms(varargin)
%INITNLMS Initialize structure for normalized LMS adaptive filter.
%   S = INITNLMS(W0,MU) returns the fully populated structure that 
%   must be used when calling ADAPTNLMS. W0 is the initial value of
%   the filter coefficients.  Its length should be equal to the filter
%   order plus one. MU is the NLMS step size.
%
%   S = INITNLMS(W0,MU,Zi) specifies the filter initial conditions.
%   It can be specified as empty, [], to get the default values, i.e.,
%   a zero vector of length one less than length(w0).
%
%   S = INITNLMS(W0,MU,Zi,LF) specifies the leakage factor LF. If specified
%   as empty, it defaults to one.
%
%   S = INITNLMS(W0,MU,Zi,LF,OFFSET) specifies an optional offset for the
%   normalization term.  This is useful to avoid divide by zero (or very small
%   numbers) if the square of input data norm becomes very small. If specified
%   as empty, it defaults to zero.
%
%   See also ADAPTNLMS, ADAPTLMS, ADAPTRLS, INITLMS, and INITKALMAN.

%   References: 
%     [1] S. Haykin, "Adaptive Filter Theory", 3rd Edition,
%         Prentice Hall, N.J., 1996.
%
%   Author(s): A. Ramasubramanian
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/11/21 16:14:30 $

warning(generatemsgid('obsolete'), ...
        ['INITNLMS is obsolete and will be removed in future versions of \n',...
            'Filter Design Toolbox. Type "help adaptfilt/nlms" and "help adaptfilt/filter"\n',...
            'for more information on using the new adaptive filters.\n']);

error(nargchk(2,5,nargin));

% Use the same initialization as LMS for all fields except the offset
S = initlms(varargin{1:min(length(varargin),4)});

% Check if offset was specified 
if nargin < 5 | isempty(varargin{5}),
	S.offset = 0;
else
	S.offset = varargin{5};
end


% [EOF]                      
