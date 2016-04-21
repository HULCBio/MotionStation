%WAITFOR timer が実行を停止するまで待機
%
% WAITFOR(OBJ) は、MATLAB コマンドラインを利用できなくし、 timer 
% オブジェクト OBJ により表わされた timer が実行を停止するまで待機します。
% timer が実行を停止する場合、timer オブジェクトの Running プロパティ
% の値は、'On' から 'Off' に変ります。
%
% OBJ が timer オブジェクトの配列である場合、WAITFOR は、すべての timer 
% が実行を停止するまで、MATLAB コマンドラインを利用できなくします。
%
% timer が実行していない場合、WAITFOR は、直ちに出力します。
%
% 参考 TIMER/START, TIMER/STOP, TIMER/WAIT.
%

% RDD 3-11-2003
% Copyright 2001-2003 The MathWorks, Inc. 
