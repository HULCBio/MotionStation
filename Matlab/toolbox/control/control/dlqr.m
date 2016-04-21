function [K,S,E] = dlqr(a,b,q,r,varargin)
%DLQR  Linear-quadratic regulator design for discrete-time systems.
%
%   [K,S,E] = DLQR(A,B,Q,R,N)  calculates the optimal gain matrix K 
%   such that the state-feedback law  u[n] = -Kx[n]  minimizes the 
%   cost function
%
%         J = Sum {x'Qx + u'Ru + 2*x'Nu}
%
%   subject to the state dynamics   x[n+1] = Ax[n] + Bu[n].  
%
%   The matrix N is set to zero when omitted.  Also returned are the
%   Riccati equation solution S and the closed-loop eigenvalues E:                            
%                               -1
%    A'SA - S - (A'SB+N)(R+B'SB) (B'SA+N') + Q = 0,   E = EIG(A-B*K).
%
%
%   See also  DLQRY, LQRD, LQGREG, and DARE.

%   Author(s): J.N. Little 4-21-85
%   Revised    P. Gahinet  7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2001/01/18 19:50:01

error(nargchk(4,5,nargin));

% Check dimensions
error(abcdchk(a,b));

try
   [K,S,E] = lqr(ss(a,b,[],[],1),q,r,varargin{:});
catch
   rethrow(lasterror);
end