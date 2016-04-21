% NKSHIFT は、データをシフトします。
%
%   DATSHIFT = NKSHIFT(DATA,NK)
%   
%   DATA: IDDATA オブジェクト
%   NK: サンプル単位のシフト量。正のシフト、負のシフト共に、どちらも使用
%       できます。
%       入力数と同じ要素数をもつ行ベクトルです。
%       正の値 nk は、入力の遅れを意味します。
%   DATSHIFT: nk(ku) ステップシフトした入力 ku をもつ IDDATA オブジェクト
% 
% NKSHIFT は、IDMODEL の InputDelay プロパティを使ったものです。
% m1 = pem(dat,4,'InputDelay',nk) は、m2 = pem(nkshift(dat,nk),4) と同じ
% モデルですが、M1 は周波数応答を計算する場合に利用される遅れ情報をもって
% います。
%
% MODEL プロパティ NK と異なることに注意してください。
% m3 = pem(dat,4,'nk',nk) は、nk サンプルの遅れを含むモデルです。
% 
% Dat1 = NKSHIFT(Dat,NK,'append') は、入力信号にゼロを追加することにより、
% Dat と同じ長さのDat1 を作成します。
%
% NK が実験の数と等しい長さのセル配列の場合、異なる遅れが各々対応する実験
% に適用されます。





%   Copyright 1986-2001 The MathWorks, Inc.
