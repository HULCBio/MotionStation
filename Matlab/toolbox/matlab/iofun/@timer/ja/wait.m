% WAIT   タイマーの実行を停止するまでの待ち時間
%
% WAIT(OBJ) は、MATLABコマンドラインをブロックし、timer オブジェクト 
% OBJ によって表されるタイマーの実行を停止するまで待ちます。タイマー
% の実行が停止するとき、timer オブジェクトの Running プロパティの値は、
% 'On' から 'Off' に変更されます。
%
% OBJ が timer オブジェクトの配列の場合、WAIT は、すべてのタイマーの
% 実行が停止するまでMATLABコマンドラインをブロックします。
%
% タイマーが実行していない場合、WAIT は即座に出力します。
%
% 参考 : TIMER/START, TIMER/STOP.


%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:57:52 $
