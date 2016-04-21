% function code = indvcmp(mat1,mat2,errcrit)
%
% 2つのVARYING行列の独立変数データを比較します。
%     CODE = 0; 独立変数データが異なる
%     CODE = 1; 独立変数データが同じ、または両者がCONSTANT行列
%     CODE = 2; 点数が異なる
%     CODE = 3; 少なくとも1つの行列がVARYINGでない、またはCONSTANTでない
%
%     ERRCRIT - 1行2列のオプション行列で、相対誤差と絶対誤差の範囲を要素
% としています。相対誤差は、独立変数の誤差の大きさが1e-9より大きいかどう
% かのテストに使われ、絶対誤差の範囲は、それより小さい独立変数値に対して
% 使われます。デフォルト値は、それぞれ1e-6と1e-13です。
%
% 参考: GETIV, SORTIV, VUNPCK, XTRACT, XTRACTI.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
