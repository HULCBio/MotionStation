function Hd = dffirt(varargin)
%DFFIRT Direct-Form FIR Transposed.
%   Hd = DFILT.DFFIRT(NUM) constructs a discrete-time FIR
%   transposed filter object.
%
%   % EXAMPLE
%   b = [0.05 0.9 0.05];
%   Hd = dfilt.dffirt(b)
%
%   See also DFILT/DFFIR, DFILT/DFSYMFIR, DFILT/DFASYMFIR.

%   Author: Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:33:55 $

Hd = dfilt.dffirt(varargin{:});

% [EOF] 
