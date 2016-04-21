% SYMSUM   シンボリックな総和
% SYMSUM(S) は、FINDSYM で決定されるようなシンボリック変数について、S の
% 無限大の総和を求めます。
% 
% SYMSUM(S, v) は、v について無限大の総和を求めます。
% SYMSUM(S, a, b) と SYMSUM(S, v, a, b)は、a から b までのシンボリック式
% の総和を求めます。
%
% 例題 :
%      simple(symsum(k))             1/2*k*(k-1)
%      simple(symsum(k,0,n-1))       1/2*n*(n-1)
%      simple(symsum(k,0,n))         1/2*n*(n+1)
%      simple(symsum(k^2,0,n))       1/6*n*(n+1)*(2*n+1)
%      symsum(k^2,0,10)              385
%      symsum(k^2,11,10)             0
%      symsum(1/k^2)                 -Psi(1,k)
%      symsum(1/k^2,1,Inf)           1/6*pi^2
%
% 参考： INT.



%   Copyright 1993-2002 The MathWorks, Inc.
