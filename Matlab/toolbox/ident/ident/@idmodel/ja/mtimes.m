%MTIMES は、IDMODELS の積を計算します。
%   Control Systems Toolbox が必要です。
%
%   MOD = MTIMES(MOD1,MOD2)
%
%   MOD = MOD1 * MOD2 を実行します。2つの LTI モデルの積を求めることは、
%   それらのシステムを直列に接続することに相当し、つぎの図のようになり
%   ます。
%
%         u ----> MOD2 ----> MOD1 ----> y 
%
%
%   注意: MTIMES は、観測入力チャンネルのみを取り扱います。ノイズ入力チャ
%         ンネルを含む相互接続を実行するためには、あらかじめ NOISECNV を
%         利用して測定チャンネルに変換しておきます。
%
%   共分散情報は、失われます。
%
%   参考:  SERIES, INV

 


%   Copyright 1986-2001 The MathWorks, Inc.
