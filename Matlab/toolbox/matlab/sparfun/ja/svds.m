% SVDS   特異値分解
% 
% A がM行N列の場合、SVDS(A,...) は EIGS(B,...) で出力される固有値と固有
% ベクトルを操作し、B = [SPARSE(M,M) A; A' SPARSE(N,N)] のときに、A の
% 特異値と特異ベクトルを求めます。対称行列 B の正の固有値は、A の特異値
% と同じです。
%
% S = SVDS(A) は、A の特異値のうち大きい6個を出力します。
%
% S = SVDS(A,K) は、A の特異値のうち大きい K 個を計算します。
%
% S = SVDS(A,K,SIGMA) は、スカラシフト SIGMA の近傍の K 個の特異値を
% 計算します。たとえば、S = SVDS(A,K,0) は、特異値のうち小さい K 個を
% 計算します。
%
% S = SVDS(A,K,'L') は、特異値のうち最大の K 個を計算します(デフォルト)。
%
% S = SVDS(A,K,SIGMA,OPTIONS) は、パラメータを設定します(EIGS を参照)。
%
% フィールド名	   パラメータ	                         デフォルト
%
% OPTIONS.tol      収束の許容値。                         1e-10
%                  NORM(A*V-U*S,1) < =  tol * NORM(A,1)
% OPTIONS.maxit    最大反復数。               	          300
% OPTIONS.disp     各繰り返しで表示する特異値の数。       0
%
% [U,S,V] = SVDS(A,...) は、特異ベクトルも計算します。A がM 行 N 列で、
% K 個の特異値が計算されると、U は列が正規直交な M 行 K 列の行列で、S は 
% K 行 K 列の対角行列、V は列が正規直交な N 行 K 列の行列です。
%
% [U,S,V,FLAG] = SVDS(A,...) は、収束のフラグも出力します。EIGS が収束
% すれば、NORM(A*V-U*S,1) < =  TOL * NORM(A,1) で、FLAG は0です。EIGS が
% 収束しなければ、FLAG は1です。
%
% 注意: SVDS は、大きいスパース行列の特異値を求めるための最も良い方法
% です。そのような行列のすべての特異値を求めるためには、SVD(FULL(A))
% は、SVDS(A,MIN(SIZE(A))) よりも適しています。
%
% 例題:
%    load west0479
%    sf = svd(full(west0479))
%    sl = svds(west0479,10)
%    ss = svds(west0479,10,0)
%    s2 = svds(west0479,10,2)
%
% sl は降順に10個の特異値を含むベクトルで、ss は昇順に10個の特異値を含む
% ベクトルで、s2 は2の近傍のwest0479の10個の特異値を含むベクトルです。
%
% 参考：SVD, EIGS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:03:38 $
