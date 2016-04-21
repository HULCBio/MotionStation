function Hd = latticeallpass(varargin)
%LATTICEALLPASS Lattice Allpass.
%   Hd = DFILT.LATTICEALLPASS(LATTICE) constructs a discrete-time lattice 
%   allpass filter object.
%
%   % EXAMPLE
%   k = [.66 .7 .44];
%   Hd = dfilt.latticeallpass(k)
%
%   See also DFILT/LATTICEAR, DFILT/LATTICEARMA, DFILT/LATTICEMAMAX,
%   DFILT/LATTICEMAMIN.

%   Author: Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:33:57 $

Hd = dfilt.latticeallpass(varargin{:});

% [EOF] 

