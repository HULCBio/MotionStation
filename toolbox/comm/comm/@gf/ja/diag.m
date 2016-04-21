% DIAG   GF行列の対角GF行列と対角要素
%
% V が N 要素のベクトルのとき、DIAG(V,K) は、K番目の対角上に V の要素を
% もつ N+ABS(K) 次の正方行列となります。K = 0 は主対角、K > 0 は主対角の
% 上側で、K < 0 は主対角の下側になります。
%
% DIAG(V) は、DIAG(V,0) と同じで、V の要素を主対角要素とします。
%
% X が行列のとき、DIAG(X,K) は、X のK番目の対角要素から作られる列ベクトル
% です。
%
% DIAG(X) は、X の主対角です。DIAG(DIAG(X)) は、対角行列です。
%
% 参考 : TRIU, TRIL.


%    Copyright 1996-2002 The MathWorks, Inc.
