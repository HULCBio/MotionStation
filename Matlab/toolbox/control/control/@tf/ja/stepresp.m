% STEPRESP   単一のLTIモデルのステップ応答を計算
%
% [Y,T,X] = STEPRESP(SYS,TS,T,T0) は、出力時間 T (t = 0で開始)で、サンプル
% 時間 TS の LTI モデル SYS のステップ応答を計算します。T0 > 0 の場合、
% t = 0 から ｔ＝T0 の応答は、切り捨てます。
%
% STEP からコールされる低水準ユーテリティです。


%	 Author: P. Gahinet, 4-98
%	 Copyright 1986-2002 The MathWorks, Inc. 
