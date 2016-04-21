function c = coefficientvariables(Hq)
%COEFFICIENTVARIABLES Coefficient variables.
%   COEFFICIENTVARIABLES(Hq) returns a cell array of the variables for the 
%   of the coefficients for this filter structure.
%
%   EXAMPLE:
%     Hq = qfilt;
%     c = coefficientvariables(Hq)
%
%   See also QFILT.   

%   Author(s): P. Costa
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:25:03 $

error(nargchk(1,1,nargin));

switch Hq.filterstructure
    case {'df1','df1t','df2','df2t'},
        c = {'Num', 'Den'};
    case {'latticearma'},
        c = {'K', 'V'};
    case {'latticeca','latticecapc'},
        c = {'L1', 'L2','B'};
    case {'latticear','latticeallpass','latticema','latticemaxphase'},
        c = {'K'};
    case 'statespace',
        c = {'A', 'B', 'C', 'D'};
    case {'fir','firt','symmetricfir','antisymmetricfir'},
        c = {'Num'};
end

% [EOF]
