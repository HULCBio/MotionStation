function S = initsd(varargin)
%INITSD Initialize structure for sign-data FIR adaptive filter.
%   S = INITSD(W0,MU) returns the fully populated structure that 
%   must be used when calling ADAPTSD. W0 is the initial value of
%   the filter coefficients.  Its length should be equal to the filter
%   order plus one. MU is the step size.
%
%   S = INITSD(W0,MU,Zi) specifies the filter initial conditions.
%   It can be specified as empty, [], to get the default values, i.e.,
%   a zero vector of length one less than length(w0).
%
%   S = INITSD(W0,MU,Zi,LF) specifies the leakage factor LF. If specified
%   as empty, it defaults to one.
%
%   See also ADAPTSD, INITSE, INITSS, ADAPTLMS, ADAPTRLS, INITLMS, and INITNLMS.

%   References: 
%     [1] M. Hayes, "Statistical Digital Signal Processing and Modeling",
%         John Wiley and Sons, N.Y., 1996.
%
%   Author(s): R. Losada
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/11/21 16:14:38 $

warning(generatemsgid('obsolete'), ...
        ['INITSD is obsolete and will be removed in future versions of \n',...
            'Filter Design Toolbox. Type "help adaptfilt/sd" and "help adaptfilt/filter"\n',...
            'for more information on using the new adaptive filters.\n']);


error(nargchk(2,4,nargin));

% Use the same initialization as LMS
S = initlms(varargin{:});


% [EOF]                      
