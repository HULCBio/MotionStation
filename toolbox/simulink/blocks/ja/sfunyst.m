% SFUNYST   グラフウィンドウを用いたS-functionストレージスコープ
%
% SFUNYSTは、Simulink S-Functionブロックにおいて利用するために設計されていま
% す。離散状態を用いて前回の入力点をストアし、時間に対してプロットします。
%
% S-functionの書式(SFUNTMPLを参照):
%  [SYS, X0]   =  SFUNYST(T,X,U,FLAG,AX,LTYPE,NPTS)
%  ここで､ AX - 初期のグラフの軸
% LTYLPE - ラインタイプ(例. 'r','r-.','x') (PLOTを参照)     NPTS - ストレー
%          ジの点数
%
% 参考 : PLOT, SFUNY, SFUNXY, LORENZ2.


% Copyright 1990-2002 The MathWorks, Inc.
