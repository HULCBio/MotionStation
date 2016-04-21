% SUBSREF は、IDMODEL モデル用のSubsref メソッドです。
% つぎのリファレンス演算は、任意の IDMODEL オブジェクト MOD に適用されま
% す。
% MOD(Outputs,Inputs) は、I/O チャンネルのサブセットを選択します。
% MOD.Fieldname は、GET(MOD,'Filedname') と等価です。
% これらの表現は、MOD(1,[2 3]).inputname や MOD.cov(1:3,1:3) のようなサブ
% スクリプト参照として正しい記法を利用できます。
%
% チャンネル参照は、チャンネル名や番号で設定されます。
%     MOD('velocity',{'power','temperature'})
% 単出力システムに対して、MOD(ku) は、入力チャンネル ku を選択し、一方、
% 単入力システムに対して、MOD(ky) は、出力チャンネル ky を選択します。
% 
% MOD('measured') は、測定入力チャンネルを選択して、ノイズ入力を無視しま
% す。
% MOD('noise') は、MOD への付加的ノイズ特性(測定入力チャンネルではない)の
% 時系列記述を与えます。
%     
% 測定チャンネルとノイズチャンネルを共に、取り扱うためには、はじめに、
% NOISECNVを使用してノイズチャンネルを変換してください。



%   Copyright 1986-2001 The MathWorks, Inc.
