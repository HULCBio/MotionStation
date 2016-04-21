% DESTIM   離散 Kalman 推定器
%
% [Ae,Be,Ce,De] = DESTIM(A,B,C,D,L) は、離散システム (A,B,C,D) をベースに、
% Kalman ゲイン行列 L を使って、Kalman 推定器を作成します。ここでは、
% システムのすべての出力はセンサ出力と仮定しています。結果求まる状態空間
% 推定器は、つぎのように表せます。
%
%    xBar[n+1] = [A-ALC] xBar[n] + [AL] y[n]
%
%     |yHat|   = |C-CLC| xBar[n] + |CL| y[n]
%     |xHat|     |I-LC |           |L |
%
% ここで、入力としてセンサ  y を考え、推定したセンサ yHat と推定した状態 
% xHat を出力としています。
%
% [Ae,Be,Ce,De] = DESTIM(A,B,C,D,L,SENSORS,KNOWN) は、SENSORS で設定した
% センサと KNOWN で指定した付加的な既知入力を使って、Kalman 推定器を作成
% します。結果のシステムは、入力として、既知の入力とセンサを使って、出力
% としてセンサと状態を推定します。KNOWN 入力は、プラントの非確率的な入力で、
% 通常、制御入力として考えます。
%
% 参考 : DLQE, DLQR, DREG, ESTIM.


%   Clay M. Thompson 7-2-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:39 $
