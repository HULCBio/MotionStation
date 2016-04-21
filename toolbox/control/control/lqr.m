function [K,S,E] = lqr(a,b,q,r,varargin)
%LQR  Linear-quadratic regulator design for continuous-time systems.
%
%   [K,S,E] = LQR(A,B,Q,R,N)  calculates the optimal gain matrix K 
%   such that the state-feedback law  u = -Kx  minimizes the cost 
%   function
%
%       J = Integral {x'Qx + u'Ru + 2*x'Nu} dt
%                                  .
%   subject to the state dynamics  x = Ax + Bu.
%
%   The matrix N is set to zero when omitted.  Also returned are the
%   Riccati equation solution S and the closed-loop eigenvalues E:
%                       -1
%     SA + A'S - (SB+N)R  (B'S+N') + Q = 0 ,    E = EIG(A-B*K) .
%
%
%   See also  LQRY, DLQR, LQGREG, CARE, and REG.

%   Author(s): J.N. Little 4-21-85
%   Revised    P. Gahinet  7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.13 $  $Date: 2002/04/10 06:24:10 $

error(nargchk(4,5,nargin));

% Check dimensions
error(abcdchk(a,b));

try
   [K,S,E] = lqr(ss(a,b,[],[]),q,r,varargin{:});
catch
   rethrow(lasterror);
end