% DYADUP 　2進アップサンプリング
% DYADUP は、ウェーブレット再構成アルゴリズムの中で、非常に有効なゼロをパッディ
% ングする単純な方法を実行します。
%
% Y = DYADUP(X,EVENODD)、ここで、X はベクトルを指しており、これにより、ゼロを内
% 挿することにより得られるベクトル X の拡張されたコピーが出力されます。正の整数 
% EVENODD の値により、ゼロを偶数のインデックスに挿入するのか、奇数のインデックス
% に挿入するのかが決定されます。
% 
% EVENODD が偶数の場合、 Y(2k-1) = X(k)、Y(2k) = 0
% EVENODD が奇数の場合、 Y(2k-1) = 0   、Y(2k) = X(k)
%
% Y = DYADUP(X) は、Y = DYADUP(X,1) と等価です。
%
% Y = DYADUP(X,EVENODD,'type')、または、Y = DYADUP(X,'type',EVENODD)(X が行列の
% 場合)は、変数'type' が、'c'(または、'r'、または、'm' のいずれか)であるかによっ
% て、行(または列、行と列の双方)を上述のパラメータ EVENODD の指定にそった形で挿
% 入し、それによって得られる X のバージョンを出力します。
%
% Y = DYADUP(X) は、Y = DYADUP(X,1,'c') と等価です。
% Y = DYADUP(X,'type') は、Y = DYADUP(X,1,'type') と等価です。
% Y = DYADUP(X,EVENODD) は、Y = DYADUP(X,EVENODD,'c') と等価です。
%
%                |1 2|                     |0 1 0 2 0|
% 例題     : X = |3 4|  ,  DYADUP(X,'c') = |0 3 0 4 0|
%
%                   |1 2|                      |1 0 2|
% DYADUP(X,'r',0) = |0 0|  , DYADUP(X,'m',0) = |0 0 0|
%                   |3 4|                      |3 0 4|
%
% 参考： DYADDOWN.



%   Copyright 1995-2002 The MathWorks, Inc.
