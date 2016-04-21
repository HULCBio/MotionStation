% THC2THD  連続時間モデルを離散時間モデルに変換
% 
%        THD = THC2THD(THC, T)
%
%   THC : THETA フォーマットで指定された連続時間モデル(THETA 参照)
%   T   : サンプリング周期
%   THD : THETA フォーマットの離散時間モデル
% 
% 入出力タイプのモデルに対して、共分散行列が離散時間に変換されないことに
% 注意してください。
%
% 参考:    THD2THC

%   Copyright 1986-2001 The MathWorks, Inc.
