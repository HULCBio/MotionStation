% SIZE   LTIモデルのサイズと次数
%
% D = SIZE(SYS) は、
%   * NU 入力 NY 出力の単一のLTIモデル SYS に対して、2要素の行ベクトル
%     D = [NY NU]
%   * NU 入力 NY 出力の単一のLTIモデルの S1*...*Sp 配列に対して、
%     行ベクトル 
%     D = [NY NU S1 S2 ... Sp] を出力します。
% 
% SIZE(SYS) は、書式付き表示を作成します。
%
% [NY,NU,S1,...,Sp] = SIZE(SYS) は、
%   * 出力数 NY
%   * 入力数 NU 
%   * LTI 配列のサイズ S1,...,Sp (LTIモデルが配列のとき)を別々の出力引数
%     に出力します。つぎのように出力を選択することもできます。
%   NY = SIZE(SYS,1) は、出力数のみを出力します。
%   NU = SIZE(SYS,2) は、入力数のみを出力します。
%   Sk = SIZE(SYS,2+k) は、k番目のLTI配列の長さを出力します。
%
% NS = SIZE(SYS,'order') は、モデルの次数(状態空間モデルに対する状態の数)
% を出力します。LTI配列の場合、すべてのモデルが同じ次数をもつ場合は、NS
% はスカラで、他の場合は、各モデル毎に配列で次数を出力します。
%
% FRDモデルの場合、
% 
%   NF = SIZE(SYS,'freq') 
% 
% は周波数点の数を出力します。
% 
% 参考 : NDIMS, ISEMPTY, ISSISO, LTIMODELS.


%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
