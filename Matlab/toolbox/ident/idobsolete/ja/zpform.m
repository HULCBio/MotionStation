% ZPFORM  ZPPLOT で利用するための異なるモデルからの極零行列
%
%   ZEPO = zpform(ZEPO1, ZEPO2, ...., KU)
%
% ZEPO1, ZEPO2,... は、ZEPO にマージされる、TH2ZP から抽出される行列です。
% KU は、オプションの行ベクトルで、ZEPO から抽出する入力番号です。デフォ
% ルトは、ZEPO1, ZEPO2,...のすべての入力です。ZPFORM は、最大で5つの入力
% 引数をとります。
%
% 例題： 
% zpplot(zpform(ZPBJ1, ZPOE1, ZPBJ2))は、異なる次数のモデルの極と零点を
% 比較します。

%   Copyright 1986-2001 The MathWorks, Inc.
