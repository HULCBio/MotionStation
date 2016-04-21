function c = privfilterstructures
%PRIVFILTERSTRUCTURES Return the list of allowable filter structures.

%   Thomas A. Bryan
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.9 $  $Date: 2002/04/14 15:28:19 $

c = {'df1', 'df1t', 'df2', 'df2t', 'fir', 'firt', 'symmetricfir', ...
      'antisymmetricfir', 'latticear', 'latcallpass', 'latticeallpass', ...
      'latticema', 'latcmax', 'latticemaxphase', 'latticearma', 'latticeca', ...
      'latticecapc', 'statespace'};
