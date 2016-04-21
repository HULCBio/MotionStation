function h = latticemamin(varargin)
%LATTICEMAMIN Lattice Moving-Average for Minimum Phase.
%   Hd = DFILT.LATTICEMAMIN(K) constructs a Lattice moving-average (MA) for
%   minimum phase discrete-time filter object with lattice coefficients K.
%   If K is not specified, it defaults to [].
%
%   See also DFILT.

% Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/13 00:00:08 $

h = dfilt.latticemamin(varargin{:});

% [EOF]
