function [abar,bbar,cbar,t,k] = obsvf(a,b,c,tol)
%OBSVF  Observability staircase form.
%
%   [ABAR,BBAR,CBAR,T,K] = OBSVF(A,B,C) returns a decomposition
%   into the observable/unobservable subspaces.
%
%   [ABAR,BBAR,CBAR,T,K] = OBSVF(A,B,C,TOL) uses tolerance TOL.
%
%   If Ob=OBSV(A,C) has rank r <= n = SIZE(A,1), then there is a 
%   similarity transformation T such that
%
%      Abar = T * A * T' ,  Bbar = T * B  ,  Cbar = C * T' .
%
%   and the transformed system has the form
%
%          | Ano   A12|           |Bno|
%   Abar =  ----------  ,  Bbar =  ---  ,  Cbar = [ 0 | Co].
%          |  0    Ao |           |Bo |
%
%                                              -1           -1
%   where (Ao,Bo) is controllable, and Co(sI-Ao) Bo = C(sI-A) B.
%
%   The last output K is a vector of length n containing the 
%   number of observable states identified at each iteration
%   of the algorithm.  The number of observable states is SUM(K).
%
%   See also  OBSV, CTRBF.

%   Author : R.Y. Chiang  3-21-86
%   Revised 5-27-86 JNL
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 06:25:03 $

% Use CTRBF and duality:

if nargin == 4
    [aa,bb,cc,t,k] = ctrbf(a',c',b',tol);
else
    [aa,bb,cc,t,k] = ctrbf(a',c',b');
end
abar = aa'; bbar = cc'; cbar = bb';
