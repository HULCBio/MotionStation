% DIAG   対角行列と行列の対角要素
% 
% VがN要素のベクトルのとき、DIAG(V,K)は、K番目の対角上にVの要素をもつ、
% N+ABS(K)次の正方行列を出力します。K = 0は主対角、K > 0は主対角の上側
% K < 0は主対角の下側に対応します。
%
% DIAG(V)は、DIAG(V,0)と同じで、Vの要素を主対角要素とします。
%
% 行列Xに対して、DIAG(X,K)はXのK番目の対角要素から作られる列ベクトルを出
% 力します。
%
% DIAG(X)は、Xの主対角です。DIAG(DIAG(X))は、対角行列です。
%
% 例題
% 
%    m = 5;
%    diag(-m:m) + diag(ones(2*m,1),1) + diag(ones(2*m,1),-1)
%  
% は、2*m+1次の3重対角行列を作成します。
%
% 参考：SPDIAGS, TRIU, TRIL.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:51:01 $
%   Built-in function.
