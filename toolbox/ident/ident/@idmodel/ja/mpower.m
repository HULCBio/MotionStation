%MPOWER は、IDMODELS のべき乗を計算します。
%   Control Systems Toolbox が必要です。
%
%   MODm = MPOWER(MOD,K)
%
%   MOD^K を計算します。ここで、MOD は任意のIDMODEL オブジェクトで、入力
%   の数と出力の数が同じであり、K が整数でなければいけません。結果のモデ
%   ル IDMODEL MODm は、IDSS オブジェクトで、つぎのようになります。
%     * K>0 の場合、 MOD * ... * MOD (K 倍) 
%     * K<0 の場合 INV(MOD) * ... * INV(MOD) (K 倍)
%     * K=0 の場合、 定常ゲイン EYE(SIZE(MOD)).
%
%   共分散情報は、変換の際に失われます。
%
%   ノイズ入力は、はじめに削除されます。
%
%   参考:   PLUS, MTIMES



%    Copyright 1986-2001 The MathWorks, Inc.
