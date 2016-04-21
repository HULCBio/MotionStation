%MODRED は、モデルを低次元化します。
%   Control Systems Toolbox が必要です。
%
%   RMOD = MODRED(MOD,ELIM)
%   RMOD = MODRED(MOD,ELIM,'mdc')
%
%   ベクトル ELIM で指定された状態を削除することにより、状態空間モデル
%   (IDSS, IDGREY オブジェクト) MOD の状態数を減らします。状態ベクトルは、
%   状態を残す X1 と、状態を削除する X2 で分離されます。
%
%       A = |A11  A12|      B = |B1|    C = |C1 C2|
%           |A21  A22|          |B2|
%       .
%       x = Ax + Bu,   y = Cx + Du  (または、対応する離散時間系)
%
%   X2 の微係数はゼロに設定され、結果の方程式は X1 に関する式です。結果の
%   システムは、LENGTH(ELIM) よりも少ない状態数をもち、ELIM 状態の応答を
%   無限に高速に設定することに相当します。オリジナルモデルと低次元化モデル
%   は、DC ゲインが一致します。つまり、定常状態応答が一致します。
%
%   RMOD = MODRED(MOD,ELIM,'del') は、状態 X2 を単純に削除します。典型的に、
%   周波数領域で良い近似特性が得られますが、DC ゲインの一致は補償されませ
%   ん。
%
%   MOD が BALREAL で平衡化され、グラミアンが M 個の小さな対角要素をもつ
%   場合、MODRED を利用して最後の M 個の状態を削除することで、モデルを低次
%   元化することができます。
%
%   参考:  BALREAL, IDSS



%   Copyright 1986-2001 The MathWorks, Inc.
