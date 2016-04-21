% LEVERAGE   回帰診断
%
% LEVERAGE(DATA,MODEL) は、回帰の各行(点)に対するレバレッジ(leverage)
% を求めます。DATA は、回帰に対する予測子変数の行列です。引数 MODEL は、
% 回帰モデルの線形次数をコントロールします。デフォルトでは、LEVERAGE は、
% 線形の加算モデルに定数項をもつものを仮定しています。MODEL は、つぎの
% 文字列を設定することができます。
%    interaction 　- 定数、線形、クロス積の項を含む
%    quadratic 　　- 二乗項を含む相対項
%    purequadratic - 定数、線形、二乗項を含む
%
% 出力 H は、レバレッジ(leverage)の値のベクトルです。H の要素は、X を項の値の
% 行列としたときの、"hat"行列 X*inv(X'*X)*X' の対角の値です。
%
% 参考 : REGSTATS.


%   B.A. Jones 1-6-94
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:12:52 $
