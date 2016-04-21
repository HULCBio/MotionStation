% GENSURF FIS 出力サーフェスの作成
%
% 表示
%    gensurf(fis)
%    gensurf(fis,inputs,output)
%    gensurf(fis,inputs,output,grids,refinput)
%
% 詳細
% gensurf(fis) は、最初の2つの入力と最初の1つの出力を使って、与えられた
% ファジィ推論システム(fis)の出力サーフェスプロットを作成します。
%
% gensurf(fis,inputs,output) は、ベクトル inputs とスカラ output でそれ
% ぞれ与えられる入力(1または2)と出力(1つのみ)を使って、プロットを作成し
% ます。
%
% gensurf(fis,inputs,output,grids) は、X 方向(1番目、水平)と Y 方向(2番
% 目、垂直)のグリッド数を設定します。grids が2要素ベクトルである場合、
% grids を X 方向と Y方向で独立して設定することができます。
%
% gensurf(fis,inputs,output,grids,refinput) は、2つより多い出力がある場
% 合に使用することができるものです。ベクトル refinput の長さは、入力の数
% と同じです。refinput には、入力サーフェスとして表示する入力部に NaN を
% 設定し、他の入力値をそのままに固定してください。
%
% [x,y,z] = gensurf(...) は、出力サーフェスを定義する変数を出力し、自動
% 的なプロットを行いません。
%
% 例題
%    a = readfis('tipper');
%    gensurf(a)
%
% 参考    SURFVIEW, EVALFIS.



%   Copyright 1994-2002 The MathWorks, Inc. 
