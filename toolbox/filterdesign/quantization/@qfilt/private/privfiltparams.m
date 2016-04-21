function [n1,n2] = privfiltparams(coeff, filterstructure);
%PRIVFILTPARAMS Java filter object.
%   [N1,N2] = PRIVFILTPARAMS(COEFF, FILTERSTRUCTURE) return filter parameters
%   N1 and N2 depending on the coefficient cell array COEFF and string
%   FILTERSTRUCTURE containing the name of the filter structure.
%
%   The definition of the parameters N1 and N2 depend on the filter structure
%   by the following table:
%
%    FILTERSTRUCTURE         N1                N2
%    df1, df1t, df2, df2t    length(b)         length(a)
%    latticearma             length(lattice)   length(ladder)
%    latticeca, latticecapc  length(lattice1)  length(lattice2)
%    otherwise               n/a               n/a

%   Thomas A. Bryan, 20 July 1999
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/04/02 22:46:31 $


n1=0; n2=0;

% Filter topology
switch filterstructure
  case {'df1', 'df1t', 'df2', 'df2t'}  % Two vectors
     b = coeff{1};
     a = coeff{2};
    n1 = length(b);
    n2 = length(a);
  case {'latticearma'}
     lattice = coeff{1};
     ladder = coeff{2};
    n1 = length(lattice);
    n2 = length(ladder);
  case {'latticeca', 'latticecapc'}
     lattice1 = coeff{1};
     lattice2 = coeff{2};
     beta = coeff{3};
    n1 = length(lattice1);
    n2 = length(lattice2);
  case {'fir', 'firt', 'latticema', 'latticear', ...
          'latcmax','latticemaxphase','latcallpass','latticeallpass',...
          'symmetricfir','antisymmetricfir'}   
  case 'statespace' % Four matrices
  otherwise
    error(['Invalid quantized filter FilterStructure: ',filterstructure])
end

