function c = coefficientnames(Hq)
%COEFFICIENTNAMES  Coefficient names.
%   COEFFICIENTNAMES(Hq) returns a cell array of the names of the
%   coefficients for this filter structure.
%
%   Example:
%     Hq = qfilt;
%     c = coefficientnames(Hq)
%
%   See also QFILT.   

%   Author: Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/04/18 13:14:52 $

switch Hq.filterstructure
 case {'df1', 'df1t', 'df2', 'df2t'}
  c = {'Numerator', 'Denominator'};
 case {'fir', 'firt', 'symmetricfir', 'antisymmetricfir'}
  c = {'Numerator'};
 case  {'latticear', 'latcallpass', 'latticeallpass', ...
        'latticema', 'latcmax', 'latticemaxphase'}
  c = {'Lattice'};
 case {'latticearma'}
  c = {'Lattice', 'Ladder'};
 case {'latticeca', 'latticecapc'}
  c = {'Lattice1', 'Lattice2', 'Beta'};
 case {'statespace'}
  c = {'A', 'B', 'C', 'D'};
end

