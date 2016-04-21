function Hd = dfasymfir(varargin)
%DFASYMFIR Direct-Form Antisymmetric FIR.
%   Hd = DFILT.DFANTISYMFIR(NUM) constructs a discrete-time direct-form
%   antisymmetric FIR filter object.
%
%   % EXAMPLE
%   b = [-0.008 0.06 -0.44 0.44 -0.06 0.008];
%   Hd = dfilt.dfasymfir(b)%
%
%   See also DFILT/DFSYMFIR, DFILT/DFFIR, DFILT/DFFIRT.

%   Author: Thomas A. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/10/30 21:33:56 $

Hd = dfilt.dfasymfir(varargin{:});

% [EOF] 
