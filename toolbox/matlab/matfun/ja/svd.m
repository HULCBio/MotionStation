% SVD   特異値分解
% 
% [U,S,V] = SVD(X) は、X と同じ大きさで、負でない対角要素を降順にもつ対角
% 行列 S と、X = U*S*V' であるようなユニタリ行列 U と V を出力します。
%
% S = SVD(X) は、特異値からなるベクトルを出力します。
%
% [U,S,V] = SVD(X,0) は、メモリ効率の良い分解を行います。X が m > n である
% m行n列の行列の場合は、U の最初のn列のみが計算され、S はn行n列になります。
% m <= n に対して、SVD(X,0) は、SVD(X) と等価です。
%
% [U,S,V] = SVD(X,'econ') は、"economy size" の分解も生成します。
% X が、m >= n として m×n の場合、SVD(X,0) に等価です。
% m < n に対して、V のはじめの m 列のみが計算され、S は、m×m です。
%
% 参考 SVDS, GSVD.

%   Copyright 1984-2002 The MathWorks, Inc. 

