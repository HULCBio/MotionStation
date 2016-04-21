% POLE   LTIモデルの極を計算
%
% P = POLE(SYS) は、LTIモデル SYS の極 P を計算します(P は、列ベクトル
% です)。
%
% 状態空間モデルに対して、極は A 行列の固有値であるか、または、ディスク
% リプタ形式での(A,E)の組の一般化固有値です。
%
% SYS がサイズ [NY NU S1 ... Sp] の LTI モデルの配列の場合、配列 P は 
% SYS と同じ次元で、P(:,1,j1,...,jp) は、LTI モデル SYS(:,:,j1,...,jp) 
% の極を含みます。相対的に極の数が少ないモデルに対しては、極のベクトル
% には、値 NaN が割り当てられます。
%
% 参考 : DAMP, ESORT, DSORT, PZMAP, ZERO, LTIMODELS.


%   Author(s): P. Gahinet, 4-9-96
%   Copyright 1986-2002 The MathWorks, Inc. 
