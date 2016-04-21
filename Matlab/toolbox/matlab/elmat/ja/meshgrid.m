% MESHGRID   3次元プロットのための配列XとY
% 
% [X,Y] = MESHGRID(x,y)は、ベクトルxとyで指定された領域を、配列XとYに変
% 換します。これは、2変数、3次元のサーフェスプロット関数の評価に使われま
% す。出力配列Xの行はベクトルxのコピーで、出力配列Yの列はベクトルyの
% コピーです。
%
% [X,Y] = MESHGRID(x)は、[X,Y] = MESHGRID(x,x)の省略形です。
% [X,Y,Z] = MESHGRID(x,y,z)は、3変数、3次元の体積プロット関数の評価に
% 使われる3次元配列を作成します。
%
% たとえば、-2 < x < 2、 -2 < y < 2の領域で関数x*exp(-x^2-y^2)を実行する
% ためには、つぎのようにします。
%
%     [X,Y] = meshgrid(-2:.2:2、-2:.2:2);
%     Z = X .* exp(-X.^2 - Y.^2);
%     mesh(Z)
%
% MESHGRIDは、最初の2つの入力引数と出力引数の順序が入れ替わっていること
% を除けば、NDGRIDと同じです(たとえば、[X,Y,Z] = MESHGRID(x,y,z)は、[Y,
% X,Z] = NDGRID(y,x,z)と同じ結果を出力します)。このため、MESHGRIDは、
% cartesian空間での問題に適していて、NDGRIDは空間と云うよりもN次元問題に
% 対して適していることがわかります。MESHGRIDは、2次元または3次元に限られ
% ます。
%
% 入力 x, y, z に対するクラスサポート:
%   float: double, single
%
% 参考 SURF, SLICE, NDGRID.

%   J.N. Little 1-30-92, CBM 2-11-92.
%   Copyright 1984-2004 The MathWorks, Inc. 
