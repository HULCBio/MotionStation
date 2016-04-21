function [kerr,serr]=dric(a,b,q,r,k,s)
%DRIC  Discrete Riccati equation residual calculation.
%
%   [Kerr,Serr] = DRIC(A,B,Q,R,K,S) Computes the error in the solution
%   to the discrete Riccati equation.  Kerr is the error in the gain
%   matrix and Serr is the residual error in the Riccati equation.
%
%                    -1                                     -1
%   Kerr = K-(R+B'SB)  B'SA;  Serr = S - A'SA + A'SB(R+B'SB)  BS'A - Q
%
%   See also  RIC, DLQE, DLQR.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:33:47 $

serr = s - a'*s*a+a'*s*b*((r+b'*s*b)\b'*s'*a)-q;
kerr = k - (r+b'*s*b)\b'*s*a;

