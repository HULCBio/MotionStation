% AUTOLINE   2つのSimulinkブロック間に体裁の良い型でラインを付加
%
% AUTOLINE(BLKNAME, FM_PORT, TO_PORT) は、Simulinkの BLKNAME 内で端子
% FM_PORT を TO_PORT に接続します。FM_PORT は、blockname/port# の形式です。
% TO_PORT は、blockname/port# の形式です。
% AUTOLINE(BLKNAME, FM_PORT, TO_PORT, BLKLOCS) は、接続ラインがBLKLOCで示さ
% れるブロックを横切らないように、Simulinkの BLKNAME の端子 FM_PORTと
% TO_PORT を接続します。BLKLOCS は、各行がブロックの左上のx-yと右下のx-yの位
% 置を表すn行4列の行列です。AUTOLINE(BLKNAME, FM_PORT, TO_PORT, BLKLOCS,
% ORIENTA) は、ORIENTA で示されている方向に FM_PORT と TO_PORT を接続します。
%  ここで、最初の要素は、FM_PORT の方向を示し、2番目の要素は、TO_PORT の方向を
% 示します。方向は、0,1,2,3によって表され、これは、左から右、下から上、右から左、
% 上から下を意味します。[LAYOUT]  =  AUTOLINE(...) は、LAYOUT の各行がx-yの位
% 置である推奨ラインレイアウトベクトルを出力します。
%


% Copyright 1990-2002 The MathWorks, Inc.
