% ZPKDATA   零-極-ゲインデータへのクイックアクセス
%
%
% [Z,P,K] = ZPKDATA(SYS) は、LTIモデル SYS の各 I/O チャンネル毎に零点、極、
% ゲインを出力します。セル配列 Z, P と行列 K は出力と同数の行と入力と同数の
% 列をもち、その (I,J) 要素は、入力 J から出力 I までの伝達関数の零点、極、ゲイン
% を表します。SYS は、必要な場合、まず初めに極-零点-ゲイン型に変換します
%
% [Z,P,K,TS] = ZPKDATA(SYS) は、サンプル時間 TS も出力します。
% SYS のその他のプロパティは、GET を用いて参照するか直接的に構造体ライクに参
% 照できます(たとえば、SYS.Ts)。
%
% 単一の SISO モデル SYS に対して、書式 [Z,P,K] = ZPKDATA(SYS,'v') は、零点
% Z と極 P をセル配列ではなく列ベクトルとして出力します。
%
% LTIモデルの配列 SYS に対して、Z, P, K は SYS と同じサイズの配列になり、m
% 番目のモデル SYS(:,:,m) の ZPK 表現は、Z(:,:,m), P(:,:,m), K(:,:,m)です。
%
% 参考 : ZPK, GET, TFDATA, SSDATA, LTIMODELS, LTIPROPS.


% Copyright 1986-2002 The MathWorks, Inc.
