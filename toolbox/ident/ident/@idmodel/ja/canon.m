%CANON は、IDMODEL オブジェクトの正準型状態空間実現を実行します。
%   Control Systems Toolbox が必要です。
%
%   CMOD = CANON(MOD,TYPE) は、IDMODEL MOD の正準型状態空間実現 CMOD を
%   計算します。TYPE は、正準構造の種類を指定します。
%     'modal'    :  Modal 正準型です。ここで、システムの固有値は対角要素
%                   になります。システム行列 A が対角化可能でなければいけ
%                   ません。
%     'companion':  Companion 正準型です。ここで、特性多項式が行列の最右
%                   列に現れます。
%
%   [CMOD,T] = CANON(MOD,TYPE) は、z = Tx により新規の状態ベクトル z を
%   古い状態ベクトル x に関連付ける状態変換行列 T も出力します。この書式
%   は、MOD が状態空間モデルの場合のみ重要です。
%
%   Modal 型は、システムのモードの可制御性を決定する場合に有効です。
%   注意: Companion 型は悪条件となるため、可能な限り避けるべきです。
%
%   外乱モデル (K-行列) は、変換において包括されます。観測入力のみに対し
%   て実行したい場合、CANON(MOD('m'),TYPE) を利用します。
%
%   共分散情報は、変換の際に失われます。
%
%   参考:  SS2SS



%   Copyright 1986-2001 The MathWorks, Inc.
