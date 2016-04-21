% NORM   行列とベクトルのノルム
% 
% 行列に対して
%   NORM(X) は、X の最大特異値 max(svd(X)) です。
%   NORM(X,2) は、NORM(X) と同じです。
%   NORM(X,1) は、X の1-ノルム、最大列和 max(sum(abs((X)))) です。
%   NORM(X,inf) は、X の無限大ノルム、最大行和 max(sum(abs((X')))) です。
%   NORM(X,'fro') は、Frobeniusノルム、sqrt(sum(diag(X'*X))) です。
%   NORM(X,P) は、P が1、2、inf、'fro' の場合のみに行列 X に対して実行
%   できます。
%
% ベクトルに対して
%   NORM(V,P) は、sum(abs(V).^P)^(1/P) です。
%   NORM(V) は、norm(V,2) です。
%   NORM(V,inf) は、max(abs(V)) です。
%   NORM(V,-inf) は、min(abs(V)) です。
% 
% 参考：COND, RCOND, CONDEST, NORMEST.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:59:58 $
%   Built-in function.

