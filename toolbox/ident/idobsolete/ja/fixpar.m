% FIXPAR   状態空間と ARX のモデル構造に対して一部のパラメータを固定
%   
%   TH = FIXPAR(TH_OLD,MATRIX,ELEMENTS,PARAMETERVALUES)
%
%   TH       : 更新された theta 行列
%   TH_OLD   : 更新前の theta 行列
%   MATRIX   : どの行列を操作するかの指定
%              ('A','B','C','D','K','X0'のどれか)
%   ELEMENTS : どの要素を操作するかの指定。n 行2列の行列。
%              ここで、各行は要素の行と列の番号です。
%              この引数が省略された場合、行列のすべての要素を固定します。
%   PARAMETERVALUES : 
%              新たに固定されるパラメータ値。
%              n 要素のベクトル。この引数が省力された場合、パラメータは、
%              TH_OLD の現在の推定値に固定されます。
%
% MATRIX が 'A1','A2',...や'B0','B1',...と定義されると、ARX 構造の対応す
% る行列が操作され、定義された TH_OLD が更新されます。
%
% 例: 
% 
%   th1 = FIXPAR(th,'A',[3,1;2,2;1,3])
%
% 注意: 
% FIXPAR は、MS2TH,ARX2TH,ARX で定義された標準的なモデル構造に対してのみ
% 機能します。TH_OLD がユーザ定義の構造に基づく場合、PEM の3番目の引数 
% INDEX を利用することで、THINIT と同じ結果を得ることができます。
%
% 参考:    ARX, ARX2TH, MS2TH, PEM, UNFIXPAR.

%   Copyright 1986-2001 The MathWorks, Inc.
