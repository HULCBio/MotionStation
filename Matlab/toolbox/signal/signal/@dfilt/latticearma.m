function h = latticearma(varargin)
%LATTICEARMA Lattice Autoregressive Moving-Average.
%   Hd = DFILT.LATTICEARMA(K, V) constructs a Lattice autoregressive
%   moving-average (ARMA) discrete-time filter object with lattice
%   coefficients K and ladder coefficients V.  If K or V are not specified,
%   the defaults [] and 1.
%
%   See also DFILT.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:00:06 $

h = dfilt.latticearma(varargin{:});

% [EOF]
