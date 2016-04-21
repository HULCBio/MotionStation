% CROSSTAB   2つの列ベクトルのクロス表
%
% CROSSTAB(COL1,COL2) は、2つの正の整数ベクトルとクロス表行列 TABLE を
% 出力します。TABLE の要素(i,j)は、COL1 = i,COL2 = j になる回数を示して
% います。
%
% [TABLE, CHI2, P] = CROSSTAB(...) は、TABLE の各次元の独立性を検定する
% カイ二乗統計量 CHI2 も出力します (すなわち、任意のセルに入るアイテムの
% 出現率は、その行の出現率の積に等しく、その列の出現率の倍であるという
% ことです)。スカラ P は、検定の信頼レベルを示します。P の値がゼロに
% 近いと独立性の仮定を疑います。
%
% [TABLE, CHI2, P, LABELS] = CROSSTAB(...) は、TABLE に対するラベルの
% セル配列も出力します。LABELS の最初の列の入力は、TABLE の行に対する
% ラベルで、以下同様に、2番目の列は2番目のラベルです。


% $Revision: 1.6 $
%   Copyright 1993-2002 The MathWorks, Inc. 
