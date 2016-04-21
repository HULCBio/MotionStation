% FILTM   SimulinkシステムMASKFILTのマスクされたブロックによるアナログ
% フィルタ設計
%
% このM-ファイルは、与えられたフィルタ設計ルーチンと周波数範囲に対して、
% 状態空間行列と周波数応答を出力します。
%
% [A,B,C,D,FREQ,MAG]  =  FILTM('FILT','TRANS',CUTOFF,BW,NPTS,P1,P2,P3)は、
% 与えられたフィルタ設計関数 'FILT' (例 'BUTTAP')とフィルタ変換法 'TRANS'
% (例 'LP2BP')に対して、状態空間行列A, B, C, Dと、周波数応答 FREQ、MAGを出力し
% ます。
%
% CUTOFF と BW は、カットオフ周波数とラジアン/秒単位のフィルタの帯域幅です。
%
% NPTS は、周波数応答を計算する点の数を定義します。
% P1, P2, P3 は、フィルタ設計パラメータです。
%
% 参考 : MASKFILT, BUTTAP, LP2BP


% Copyright 1990-2002 The MathWorks, Inc.
