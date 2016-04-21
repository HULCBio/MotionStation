% WCODEMAT　 拡大された疑似カラー行列のスケーリング
% Y = WCODEMAT(X,NB,OPT,ABSOL) は、最初の NB 個の整数を使って、ABSOL が 0 の場合、
% 入力行列 X のコード化されたバージョンを出力し、ABSOL が0でない場合、ABS(X) を
% 出力します。符号化は、行ベース(OPT = 'row' または 'r')、列ベース(OPT = 'col' 
% または 'c')、グローバル的(OPT = 'mat' または 'm')のいずれかの方式で行うことが
% できます。符号化は、各行(列、または、行列)の最小値と最大値の間で、定間隔のグリ
% ッドを使います。
% 
% Y = WCODEMAT(X,NB,OPT) は、Y = WCODEMAT(X,NB,OPT,1) と等価です。
% Y = WCODEMAT(X,NB) は、Y = WCODEMAT(X,NB,'mat',1) と等価です。
% Y = WCODEMAT(X) は、Y = WCODEMAT(X,16,'mat',1) と等価です。



%   Copyright 1995-2002 The MathWorks, Inc.
