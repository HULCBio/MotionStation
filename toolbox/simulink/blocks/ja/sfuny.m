% SFUNY   グラフウィンドウを用いたS-functionスコープ
%
% このM-ファイルは、Simulink S-Functionブロックにおいて利用するために設計さ
% れています。離散状態を用いて最終入力点をストアし、時間に対してプロットしま
% す。
%
% S-functionの書式(SFUNTMPLを参照):
%  [SYS, X0]   =  SFUNY(T,X,U,FLAG,AXISLIMITS,LTYPE,SAMPLETIME)
%  ここで､ AXISLIMITS - グラフの軸の範囲
% LINESTYLES - ラインタイプ(例. 'r','r-.','x') (PLOTを参照) SAMPLETIME -
%              このブロックのサンプル時間
%
% 関数パラメータは、グラフの軸を定義する4要素ベクトルとして設定してください。
% ラインタイプは、コーテーション内で指定しなければなりません。
%
% 参考 : PLOT, SFUNYST, SFUNXY.


% Copyright 1990-2002 The MathWorks, Inc.
