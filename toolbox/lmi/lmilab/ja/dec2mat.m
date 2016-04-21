% X = dec2mat(lmisys,decvars,k);
%
% 決定変数のベクトルの値DECVARSが与えられたとき、DEC2MATは、K番目の行列
% 変数の対応する行列値Xを出力します(より一般的には、ラベルKの変数の値)。
% DECVARSは、ある最適化手続きの出力であることに注意してください。
%
% 入力:
%   LMISYS     連立LMIを記述する配列
%   DECVARS    決定変数値のベクトル
%   K	       LMIVARによって出力された注目する変数行列の識別子
%
% 出力:
%   X          Xkの行列の値
%
% 参考：    MAT2DEC, DECINFO, DECNBR, LMIVAR.



% Copyright 1995-2002 The MathWorks, Inc. 
