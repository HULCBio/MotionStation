% DREG   離散のLQG コントローラ
%
% [Ac,Bc,Cc,Dc] = DREG(A,B,C,D,K,L) は、離散システム(A, B, C, D)をベースに、
% フィードバックゲイン行列 K、Kalman ゲイン行列 L を使って、システム入力は
% 制御入力、システムのすべての出力は、センサ出力であるとの仮定のもとで、
% LQG コントローラを作成します。結果の状態空間コントローラは、つぎのように
% なります。
%
%   xBar[n+1] = [A-ALC-(B-ALD)E(K-KLC)] xBar[n] + [AL-(B-ALD)EKL] y[n]
%   uHat[n]   = [K-KLC+KLDE(K-KLC)]     xBar[n] + [KL+KLDEKL]     y[n]
%
% ここで、E = inv(I+KLD) で、入力としてセンサ y 、出力として制御フィード
% バック指令 uhat です。コントローラは、負のフィードバックを使って、
% プラントに結合します。
% 
% [Ac,Bc,Cc,Dc] = DREG(A,B,C,D,K,L,SENSORS,KNOWN,CONTROLS) は、SENSORS で
% 設定されるセンサ、KNOWN で設定される付加既知入力、CONTROLS で設定される
% 制御入力を使って、LQG コントローラを作成します。結果のシステムは、制御
% フィードバック指令を出力とし、既知入力とセンサを入力とします。KNOWN 
% 入力は、プラントの非確率的な入力で、通常、付加的な制御入力または指令
% 入力です。
%
% 参考 : DESTIM, DLQR, DLQE, REG.


%   Clay M. Thompson 7-2-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:54 $
