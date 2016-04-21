function [m, p] = sigmpoles(p, varargin)
%SIGMPOLES Returns the multiplicity of poles
%   [M, P] = SIGMPOLES(P, TOL) Returns the multiplicity of poles in M and
%   the matching poles in the vector P.  TOL is passed to MPOLES and not
%   used elsewhere.  See the help of MPOLES for more information.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:46:45 $

[m, i] = mpoles(p, varargin{:});

idx = [find(diff(m) < 0 | diff(m) == 0); length(m)];

m = m(idx);
p = p(i(idx));

% [EOF]
