% TOTALDELAY   入力と出力間でのむだ時間の総和
%
%
% TD = TOTALDELAY(SYS) は、LTI モデル SYS の I/O のむだ時間の総和 TD を出力
% します。行列 TD は、プロパティ INPUTDELAY, OUTPUTDELAY,IODELAYMATRIX のむだ
% 時間を組み合わせます(これらのプロパティについて詳細は、LTIPROPS を参照して
%
% 連続時間モデルの場合、むだ時間は秒で表現され、離散時間モデルの場合、サンプル
% 間隔の整数倍で表現されます(むだ時間を秒で得るために、サンプル時間 SYS.
% TS を TD に掛け合わせてください)。
%
% 参考 : HASDELAY, DELAY2Z, LTIPROPS.


% Copyright 1986-2002 The MathWorks, Inc.
