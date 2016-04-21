% MU2LIN   mu-則から線形信号への変換
% 
% Y = MU2LIN(MU)は、0 < =  MU < =  255の範囲で"flints"として保存されてい
% るmu-則の符号化8ビットの音声信号を、s = 32124/32768 ~ =  .9803での -s 
% < Y < sの範囲で線形な信号に変換します。入力MUは、バイトエンコード音声
% ファイルの読み込みのために、fread(...,'uchar')を使って得られます。
% "Flints"は、MATLABの整数です(値が整数である浮動小数値です)。
%
% 参考：LIN2MU, AUREAD.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:45:12 $
