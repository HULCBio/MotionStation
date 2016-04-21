% BARTTEST   X 内のデータの次元に関する Bartlett 検定
%
% [NDIM, PROB, CHISQUARE] = BARTTEST(X,ALPHA) は、データ行列 X と有意
% 確率 ALPHA を必要とします。この関数は、X の中の非ランダム的な変動を
% 説明するために必要な次元数を出力します。次元数は、X の中の共分散行列の
% 最大の重複しない固有値の数と等しいと仮定します。
% 
% CHISQUARE は、連続的に仮説を1,2,3,...等の次元に設定したときの検定
% 統計量を示すベクトルです。
% PROB は、CHISQUARE の各要素に対応する有意確率を表わすベクトルです。


%   B. Jones 3-17-94
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:08:55 $
