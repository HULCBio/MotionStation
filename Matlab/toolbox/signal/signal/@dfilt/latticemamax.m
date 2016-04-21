function h = latticemamax(varargin)
%LATTICEMAMAX Lattice Moving-Average for Maximum Phase.
%   Hd = DFILT.LATTICEMAMAX(K) constructs a Lattice moving-average (MA) for
%   maximum phase discrete-time filter object with lattice coefficients K.
%   If K is not specified, it defaults to [].
%
%   See also DFILT.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:00:07 $

h = dfilt.latticemamax(varargin{:});

% [EOF]
