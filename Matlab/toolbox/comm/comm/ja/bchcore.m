% BCHCORE   BCH復号のコア部
%
% [MSG, ERR, CCODE] = BCHCORE(CODE, POW_DIM, DIM, K, T, TP)は、BCH符号を
% 復号します。
% CODEは列サイズが POW_DIM であるコードワード行ベクトルです。POW_DIMは
% 2^DIM -1 と等価です。K はメッセージの長さ、T は誤り訂正能力です。TP は
% GF(2^DIM) の要素の全てのリストです。
% 
% この関数は、SIMULINKファイルとMATLAB関数間で情報を共有することができ
% ます。直接呼び出せるようには設計されていません。オーバヘッドを減らす
% ために、この関数では誤りチェックを実行しません。


%       Wes Wang 8/5/94, 9/30/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.5.4.1 $
