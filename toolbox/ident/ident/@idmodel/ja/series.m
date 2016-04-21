%SERIES は、2つのIDMODELの直列接続を実行します。
%   Control Systems Toolbox が必要です。
%
%                                  +------+
%                           v2 --->|      |
%                  +------+        | MOD2 |-----> y2
%                  |      |------->|      |
%         u1 ----->|      |y1   u2 +------+
%                  | MOD1 |
%                  |      |---> z1
%                  +------+
%
%   MOD = SERIES(MOD1,MOD2,OUTPUTS1,INPUTS2)
%
%   2つの IDMODELS MOD1 と MOD2 を直列に接続し、OUTPUTS1 で指定された MOD1
%   の出力が、INPUTS2 で指定された MOD2 の入力に接続されます。ベクトル
%   OUTPUTS1 と INPUTS2 は、それぞれ MOD1 と MOD2 の出力と入力のインデッ
%   クスです。結果の IDMODEL MOD は、IDSS オブジェクトで、u1 を y2 にマッ
%   プします。
%
%   OUTPUTS1 と INPUS2 が省略されると、MOD1 と MOD2 がカスケードに接続さ
%   れ、つぎのシステムを出力します。
%                     MOD = MOD2 * MOD1 .
%
%   注意: SERIES は、観測入力チャンネルのみを取り扱います。ノイズ入力チャ
%         ンネルも同時に相互接続するためには、あらかじめ NOISECNV を利用
%         して測定チャンネルに変換しておく必要があります。
%
%   共分散情報は、失われます。
%
%   参考:  APPEND, PARALLEL, FEEDBACK



%   Copyright 1986-2001 The MathWorks, Inc.
