function [G, W, Gr] = grpdelay(Hq, varargin)
%GRPDELAY Group delay of a digital filter.
%   [G, W, Gr] = GRPDELAY(Hq, N) returns length N vectors G and W
%   containing the group delay and the frequencies (in radians) at which it
%   is evaluated.  Gr is the group delay of the reference coefficients.
%   See signal/grpdelay for more information.

%   Author(s): J. Schickler
%   Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:25:09 $

[b, a, br, ar] = tf(Hq);

[G, W] = grpdelay(b,  a,  varargin{:});
Gr     = grpdelay(br, ar, varargin{:});

% [EOF]
