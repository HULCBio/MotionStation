% TFDATA   伝達関数データへのクイックアクセス
%
%
% [NUM,DEN] = TFDATA(SYS) は、伝達関数 SYS の分子多項式と分母多項式を出力し
% ます。NU 入力、NY 出力の伝達関数に対して、NUM と DEN は、NY*NU のセル配列で
% (I,J) 要素は、入力 J から出力 I までの伝達関数を表します。SYS は、必要な場合、
% まず、初めに伝達関数への変換を行います。
%
% [NUM,DEN,TS] = TFDATA(SYS) は、サンプル時間 TS も出力します。
% SYS のその他のプロパティは、GET を用いて参照するか直接的に構造体ライクに参
% 照できます(たとえば、SYS.Ts)。
%
% SISOモデル SYS では、書式、 [NUM,DEN] = TFDATA(SYS,'v') は、セル配列ではなく、
% 行ベクトルで分子多項式と分母多項式を出力します。
%
% LTIモデルの配列 SYS に対して、NUM と DEN は、SYS と同じサイズの NDセル配列
% で、NUM(:,:,k) と DEN(:,:,k) は k 番目のモデル SYS(:,:,k) の伝達関数を表し
% ます。
%
% 参考 : TF, GET, ZPKDATA, SSDATA, LTIMODELS, LTIPROPS.


% Copyright 1986-2002 The MathWorks, Inc.
