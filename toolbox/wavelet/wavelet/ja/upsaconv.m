% UPSACONV　 アップサンプルとコンボリューションを行います。
%
% Y = UPSACONV('1D',X,F_R) は、フィルタ F_R を使って1ステップの2進補間(アップサ
% ンプルとコンボリューション)を行った結果を出力します。
%
% Y = UPSACONV('1D',X,F_R,L) は、Y = UPSACONV('1D',X,F_R) の結果から、中央部を L
% の長さだけ取り出します。
%
% Y = UPSACONV('2D',X,{F1_R,F2_R}) は、行方向にフィルタ F1_R を、列方向にフィル
% タ F2_R を使って、行列 X の1ステップの2進補間(アップサンプルとコンボリューショ
% ン)の結果を出力します。
%
% Y = UPSACONV('2D',X,{F1_R,F2_R},S) は、Y = UPSACONV('2D',X,{F1_R,F2_R}) から得
% られる結果から中央部をサイズ S だけ取り出します。
%
% Y = UPSACONV('1D',X,F_R,DWTATTR) は、DWTATTR で記述されるアップサンプルとコン
% ボリューションの属性によるフィルタ F_R を使って、1ステップのベクトル X の補間
% を行った結果を出力します。
%
% Y = UPSACONV('1D',X,F_R,L,DWTATTR) は、他の使用法の2つを結合して計算します。
%
% Y = UPSACONV('2D',X,{F1_R,F2_R},DWTATTR) は、DWTATTR で記述されるアップサンプ
% ルとコンボリューションの属性によるフィルタ F1_R と F2_R を使って、行列 X の1ス
% テップ補間を行った結果を出力します。
%
% Y = UPSACONV('2D',X,{F1_R,F2_R},S,DWTATTR) は、他の使用法を結合して計算します。



%   Copyright 1995-2002 The MathWorks, Inc.
