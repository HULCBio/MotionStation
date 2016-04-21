% DELAY2Z   z=0 での極、または、周波数応答データ(FRD)の位相シフトによる 遅れの
% 置き換え
%
%
% 離散時間の TF, ZPK または SS モデル SYS に対して、 SYS = DELAY2Z(SYS) は、
% すべての時間遅れを Z = 0 の極へマッピングします。つまり、kサンプル分の遅れ
% は、(1/z)^k で置き換えられます。
%
% 状態空間モデルに対して、[SYSND,G] = DELAY2Z(SYS) は、SYS の初期状態 x0 を
% SYSNDの対応する初期状態 G*x0 に マッピングする行列 G も出力します。
%
% FRD モデルに対して、DELAY2Z は、すべての時間遅れを周波数応答データに吸収させ
% ます。 連続時間、離散時間 FRD のどちらに対しても適用できます。
%
% 参考 : HASDELAY, PADE, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
