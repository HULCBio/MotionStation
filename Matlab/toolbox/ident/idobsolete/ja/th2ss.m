% TH2SS  THETA フォーマットのモデルを状態空間に変換
%  
%         [A, B, C, D, K, X0] = TH2SS(TH)
%
%   TH : THETA フォーマットで定義されたモデル(THETA 参照)
%   A, B, C, D, K, X0 : 状態空間記述の行列
%
%         Xn = A X + B u + K e       X0:初期値
%         y  = C X + D u + e
%
% ここで、TH が連続時間の場合 Xn は X の微分で、離散時間の場合 X のつぎ
% の値です。
%
% [A, B, C, D, K, X0, dA, dB, dC, dD, dK, dX0] = TH2SS(TH)と実行すると、
% 行列要素の標準偏差が出力されます。
%
% 参考:    TH2FF, TH2POLY, TH2TF, TH2ZP

%   Copyright 1986-2001 The MathWorks, Inc.
