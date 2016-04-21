%PLUS は、2つの IDMODEL モデルを加算します。
%   Control Systems Toolbox が必要です。
%
%   MOD = PLUS(MOD1,MOD2)
%
%   MOD = MOD1 + MOD2 を実行します。モデルを加算することは、それらのモデ
%   ルを並列接続することと等価です。
%
%   注意: PLUS は、観測入力チャンネルのみを取り扱います。ノイズ入力チャン
%         ネルを含む相互接続を実行するためには、あらかじめ NOISECNV を利
%         用して測定チャンネルに変換しておく必要があります。
%
%   共分散情報は、失われます。
%
%   参考:  PARALLEL, MINUS, UPLUS



%   Copyright 1986-2001 The MathWorks, Inc.
