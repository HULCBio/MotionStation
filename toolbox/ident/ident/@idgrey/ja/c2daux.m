% IDGREY/C2D は、連続時間モデルを離散時間モデルに変換します。
%
%   SYSD = C2D(SYSC,Ts,METHOD)
%
%   SYSC  : 連続時間モデル、IDGREY オブジェクト
%
%   Ts    : サンプリング間隔
%
%   METHOD: 'Zoh' (デフォルト)、または、'Foh'で、入力をゼロ次ホールド
%          (区分的定数)か、一次ホールド(区分的線形)のいずれかであると
%          仮定していることに対応します。
%
% プロパティ CDmfile = 'cd' の場合、SYSD は、M-ファイル自身のサンプ
% リングをもつ IDGREY オブジェクトとして出力されます。
%
% その他の場合、離散時間モデル SYSD は、'SSParameterization' = 'Free'
% をもつ IDSS オブジェクトです。この場合、共分散行列が更新されないこと
% に注意してください。



%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2001 The MathWorks, Inc.
