% AUWRITE   NeXT/SUN (".au")サウンドファイルの書き出し
% 
% AUWRITE(Y,AUFILE)は、文字列AUFILEで指定されたサウンドファイルを書き出
% します。データは、列毎に1チャンネルを表しています。[-1,+1]の範囲外の振
% 幅値は、書き出す前に切り取ります。
%
% サポートしているマルチチャンネルデータは、 8-ビット mu-則、8-ビットと
% 16ビットの線形形式です。
%
% AUWRITE(Y,Fs,AUFILE)は、データのサンプリングレイトをヘルツで表わします。
%
% AUWRITE(Y,Fs,BITS,AUFILE)は、符号化のビット数を選択します。可能な設定
% は、BITS = 8とBITS = 16のどちらかです。
%
% AUWRITE(Y,Fs,BITS,METHOD,AUFILE)は、'mu'、または、'linear'のどちらかに
% よる符号化の方法を設定します。mu-則のファイルは8-ビットです。デフォル
% トは、method = 'mu'です。
%
% 参考：AUREAD, WAVWRITE.

% Copyright 1984-2004 The MathWorks, Inc. 

