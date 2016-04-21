% GETFF  (自分自身のプロットのために)周波数関数を抽出
% 
%   [W,AMP,PHAS] = GETFF(G,NU,NY)
%
% W    : ラジアン/秒の周波数スケール
% AMP  : 振幅関数
% PHAS : 位相関数(度)
% G    : FREQFUNC フォーマットの周波数関数。FREQFUNC を参照してください。
% NU   : 入力番号(雑音入力は、入力番号0として定義)
%       (デフォルトは１。G がすべてのスペクトルを含む場合、デフォルトは0)
% NY   : 出力番号 (デフォルトは1)
%
% G のいくつかの要素が同じ入出力関係に対応する場合、W, AMP, PHAS は対応
% する列数をもちます。
%
% つぎの書式で、振幅の標準偏差と位相の標準偏差が出力されます。
%
%    [W,AMP,PHAS,SD_AMP,SD_PHAS] = GETFF(G,NU,NY)

%   Copyright 1986-2001 The MathWorks, Inc.
