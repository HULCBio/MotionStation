% IDFRD/BODERESP は、モデルの周波数関数とその標準偏差を計算します。
% 
% [MAG,PHASE,W] = BODERESP(G)   
%
% ここで、G は、IDFRD オブジェクトです。MAG は応答のゲインで、PHASE は位
% 相(単位は度)です。G.Frequency の周波数に対して応答が計算され、ベクトル
% W に出力されます。周波数単位は rad/s で、G.UNITS は無効です。
%
% M が、NY 出力、NU 入力をもち、W が周波数点 NW 個をもっている場合、MAG 
% と PHASE は、MAG(ky,ku,k) が、入力 ku から出力 ky までの周波数 W(k) で
% の応答を示す NY-NU-NW の配列です。
%
% M が時系列の場合、MAG はそのパワースペクトルを出力し、PHASE は常にゼロ
% になります。
% この関数は、離散時間モデルでも、連続時間モデルでも機能します。
% BODERESP(M('noise')) を使って、モデル M の出力に関連した擾乱(ノイズ)ス
% ペクトルを得ます。BODERESP(M(ky,ku)) を使って、特定な入力/出力の応答に
% アクセスできます。
%
% [MAG,PHASE,W,SDMAG,SDPHAS] = BODERESP(M) を使って、ゲインと位相の標準偏
% 差も計算できます。
%   
% 参考： BODE, FFPLOT, NYQUIST and IDFRD.


%   L. Ljung 7-7-87,1-25-92


%   Copyright 1986-2001 The MathWorks, Inc.
