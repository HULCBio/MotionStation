%function [indv,err] = getiv(mat,iv_index)
%
% VARYING行列MATの独立変数値を出力します。独立変数は、列ベクトルとして出
% 力され、ERR = 0と設定されます。MATがVARYING行列でなければ、INDVは空行
% 列に設定され、ERR = 1と設定されます。2つの引数を設定すると、インデック
% スIV_INDEXの正の整数ベクトルに対応する独立変数のみを出力します。
%
% 参考: INDVCMP, SORT, SORTIV, TACKON, XTRACT, XTRACTI



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
