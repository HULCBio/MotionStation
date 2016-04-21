% POLE   LTIモデルの極を計算
%
%
% P = POLE(SYS) は、LTIモデル SYS の極 P を計算します(P は、列ベクトルです)。
%
% 状態空間モデルに対して、極は A 行列の固有値であるか、または、ディスクリプタ
% 形式での(A,E)の組の一般化固有値です。
%
% SYS がサイズ [NY NU S1 ... Sp] のLTIモデルの配列の場合、配列 P はSYS と
% 同じ次元で、P(:,1,j1,...,jp) は、LTI モデル SYS(:,:,j1,...,jp)の極を含みます。
% 相対的に極の数が少ないモデルに対しては、極のベクトルには、値 NaN が割り当て
% られます。
%
% 参考 : DAMP, ESORT, DSORT, PZMAP, ZERO, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
