function savefipref
%SAVEFIPREF  Save fixed-point preferences.
%   SAVEFIPREF Saves the current fixed-point preferences to the
%   preferences file so that it will be persistent between MATLAB
%   sessions.
%
%
%   Examples:
%     % These MATLAB display options affect the display of all numeric objects.
%     format compact
%     format long g
%
%     % These display preferences are specific to the fi object.
%     p = fipref;
%     p.NumberDisplay      = 'RealWorldValue';
%     p.NumericTypeDisplay = 'short';
%     p.FimathDisplay      = 'none';
%
%     a = fi(pi)
%       % a =
%       %               3.1416015625
%       %       s16,13
%
%     savefipref  % Saves fi display preferences for next MATLAB session
%
%
%   See also FI, FIMATH, FIPREF, NUMERICTYPE, QUANTIZER, FIXEDPOINT.

%   Thomas A. Bryan, 5 April 2004
%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/20 23:18:42 $

P = fipref;
P.savefipref;
