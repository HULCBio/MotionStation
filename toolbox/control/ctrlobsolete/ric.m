function [kerr,serr] = ric(a,b,q,r,k,s,n)
%RIC  Riccati residual calculation.
%
%   [Kerr,Serr] = RIC(A,B,Q,R,K,S) Computes the error in the solution
%   to the Riccati equation.  Kerr is the error in the gain matrix
%   and Serr is the residual error in the Riccati equation.
%                 -1                           -1
%       Kerr = K-R  B'S;  Serr = SA + A'S - SBR  B'S + Q
%
%   [Kerr,Serr] = RIC(A,B,Q,R,K,S,N) computes the error in the 
%   solution to the Riccati equation with cross weighting term.
%             -1                                    -1
%   Kerr = K-R  (N'+B'S);  Serr = SA + A'S - (SB+N)R  (N'+B'S) + Q
%
%   See also  DRIC, ARE, LQE, and LQR.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:32:29 $

if nargin == 7
    serr = s*a + a'*s - (s*b+n)/r*(n'+b'*s) + q;
    kerr = k - r\(n'+b'*s);
else
    serr = s*a+a'*s-s*b/r*b'*s+q;
    kerr = k - r\b'*s;
end
