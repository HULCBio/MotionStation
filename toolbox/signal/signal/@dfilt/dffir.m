function Hd = dffir(varargin)
%DFFIR Direct-Form FIR.
%   Hd = DFILT.DFFIR(NUM) constructs a discrete-time FIR
%   filter object.
%  
%   % EXAMPLE
%   b = [0.05 0.9 0.05];
%   Hd = dfilt.dffir(b)
%
%   See also DFILT/DFFIRT, DFILT/DFSYMFIR, DFILT/DFASYMFIR.

%   Author: Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:33:54 $

Hd = dfilt.dffir(varargin{:});

% [EOF] 
