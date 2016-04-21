% PDEIGEOM PDE 形状の解釈
% PDEIGEOM の最初の入力引数は、形状記述を設定するものです。最初の引数が
% テキストの場合、テキストは、残りの引数と共にコールされる関数名として使
% われます。この関数は、形状 M-ファイルになり、PDEIGEOM と同じ結果を出力
% します。最初の引数がテキストでない場合、Decomposed Geometry Matrix と
% 仮定されています。詳細は、DECSG または PDEGEOM を参照してください。
%
% NE = PDEIGEOM(DL) は、境界セグメントの数を求めます。
%
% D = PDEIGEOM(DL,BS) は、BS で指定されている各境界セグメントに対して1列
% を割り当てている行列です。
% 
% 1行目は、最初のパラメータ値です。
% 2行目は、最後のパラメータ値です。
% 3行目は、左側の領域のラベルです。
% 4行目は、右側の領域のラベルです。
%
% [X,Y] = PDEIGEOM(DL,BS,S) は、境界点の座標を表示します。BS は、境界セ
% グメントを設定し、S は対応するパラメータ値を設定します。BS は、スカラ
% でも構いません。
%
% 参考   INITMESH, REFINEMESH, PDEGEOM, PDEARCL

%       Copyright 1994-2001 The MathWorks, Inc.
