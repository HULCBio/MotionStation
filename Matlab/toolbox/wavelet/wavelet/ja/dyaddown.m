% DYADDOWN 　2進ダウンサンプリング
% Y = DYADDOWN(X,EVENODD)、X はベクトルで、X を1つ飛びにダウンサンプルしたものを
% 出力します。Y は、正の整数 EVENODD の値によって、X の偶数インデックスか奇数イ
% ンデックスになります。
% 
% EVENODD が偶数の場合、Y(k) = X(2k)
% EVENODD が奇数の場合、Y(k) = X(2k-1)
%
% Y = DYADDOWN(X) は、Y = DYADDOWN(X,0) と等価です。
%
% Y = DYADDOWN(X,EVENODD,'type')、または、Y = DYADDOWN(X,'type',EVENODD)(X が行
% 列の場合)は、変数 'type' が、'c' または 'r' または 'm' であるかによって、行(ま
% たは列、行と列の双方)を上述のパラメータ EVENODD の指定にそった形で削除し、それ
% によって得られる X のバージョンを出力します。
%
% Y = DYADDOWN(X) は、Y = DYADDOWN(X,0,'c') と等価です。
% Y = DYADDOWN(X,'type') は、Y = DYADDOWN(X,0,'type') と等価です。
% Y = DYADDOWN(X,EVENODD) は、Y = DYADDOWN(X,EVENODD,'c') と等価です。
%
%                |1 2 3 4|                       |2 4|
% 例題 :     X = |2 4 6 8|  ,  DYADDOWN(X,'c') = |4 8|
%                |3 6 9 0|                       |6 0|
%
%                     |1 2 3 4|                        |1 3|
% DYADDOWN(X,'r',1) = |3 6 9 0|  , DYADDOWN(X,'m',1) = |3 9|
%
% 参考： DYADUP.



%   Copyright 1995-2002 The MathWorks, Inc.
