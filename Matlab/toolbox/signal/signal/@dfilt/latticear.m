function Hd = latticear(varargin)
%LATTICEAR Lattice Autoregressive (AR).
%   Hd = DFILT.LATTICEAR(LATTICE) constructs a discrete-time lattice AR
%   filter object.
%
%   % EXAMPLE
%   k = [.66 .7 .44];
%   Hd = dfilt.latticear(k)
%
%   See also DFILT/LATTICEALLPASS, DFILT/LATTICEARMA, DFILT/LATTICEMAMAX,
%   DFILT/LATTICEMAMIN.

%   Author: Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:33:57 $

Hd = dfilt.latticear(varargin{:});

% [EOF] 
  
