function Hd = scalar(varargin)
%SCALAR Scalar.
%   Hd = DFILT.SCALAR(G) constructs a discrete-time scalar
%   filter object with gain G.
%
%   % EXAMPLE
%   Hd = dfilt.scalar(3)
%
%   See also DFILT/CASCADE, DFILT/PARALLEL.

%   Author: Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:33:50 $

Hd = dfilt.scalar(varargin{:});

% [EOF] 

  
