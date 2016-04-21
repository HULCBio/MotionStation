% GFTRUNC   多項式表現の長さを最小化
%
% C = GFTRUNC(A) は、GF(P) 多項式 A の高次の項から係数が0である項を取り
% 除きます。最も次数の高い項の係数が0以外の数である場合、この関数の出力
% は入力と等しくなります。その結果となる GF(P) 上の多項式 C は、A の
% 省略形と同じです。
% 
% A は昇ベキ順に並べられた多項式係数を指定する行ベクトルです。
%
% 参考： GFADD, GFSUB, GFCONV, GFDECONV, GFTUPLE.



%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/06/23 04:34:50 $
