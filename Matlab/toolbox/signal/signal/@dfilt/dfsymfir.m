function Hd = dfsymfir(varargin)
%DFSYMFIR Direct-Form Symmetric FIR.
%   Hd = DFILT.DFSYMFIR(NUM) constructs a discrete-time direct-form
%   symmetric FIR filter object.
%
%   % EXAMPLE
%   b = [-0.008 0.06 0.44 0.44 0.06 -0.008];
%   Hd = dfilt.dfsymfir(b)
%
%   See also DFILT/DFASYMFIR, DFILT/DFFIR, DFILT/DFFIRT.

%   Author: Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:33:56 $

Hd = dfilt.dfsymfir(varargin{:});

% [EOF] 
