function msg = commblkwininteg(block)
% COMMBLKWININTEG Helper function for Windowed Integrator block.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/28 12:39:41 $

% Init variables
msg = [];

%-- Get value from mask
integPeriod = str2num(get_param(block, 'integperiod'));

%- Error if empty, non-numeric, non-integer, vector or less than 1.
if isempty(integPeriod) || ~isnumeric(integPeriod) || ...
        ~isscalar(integPeriod) || ~isreal(integPeriod) || ...
       ~isinteger(integPeriod) || integPeriod <= 1  
    msg = 'Integration Period must be a positive integer number.';
end

%[EOF]