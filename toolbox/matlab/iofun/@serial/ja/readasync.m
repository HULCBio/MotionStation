% READASYNC   デバイスから非同期状態でデータを読み込み
%
% READASYNC(OBJ) は、serial port オブジェクト OBJ に接続されたデバイス
% から非同期状態で、データを読み込みます。READASYNC は、コントロールを、
% その後、すぐに MATLAB に戻します。
%
% 読み込んだデータは、入力バッファにストアされます。BytesAvailable プロ
% パティは、入力バッファ内で利用可能なバイト数を示します。
%
% READASYNC は、つぎに事柄の内の一つが生じると読み込みを停止します。:
%     1. Terminator プロパティで指定された終端子を受け取る
%     2. Timeout プロパティで指定された時間切れが発生する
%     3. 入力バッファがいっぱいになる
% 
% serial port オブジェクト OBJ は、任意のデータがデバイスから読み込まれる
% 前に FOPEN 関数を使ってデバイスに接続していなければなりません。その他の
% 場合は、エラーが出力されます。接続された serial port オブジェクトは、
% open の Status プロパティ値をもっています。
%
% READASYNC(OBJ, SIZE) は、デバイスから、多くても SIZE バイトを読み込み
% ます。
% SIZE が OBJ の InputBufferSize プロパティ値と OBJ の BytesAvailable
% プロパティ値の差分よりも大きい場合、エラーが返されます。
%
% TransferStatus プロパティは、非同期的な操作が進行中か否かを示します。
%
% 非同期的な読み込みの進行中に READASYNC がコールされた場合、エラーが
% 出力されます。しかし、非同期的な読み込みが進行している間の書き込みは
% 可能です。
%
% STOPASYNC 関数は、非同期的な読み込み操作を停止するのに使われます。
%
% 例題:
%      s = serial('COM1', 'InputBufferSize', 5000);
%      fopen(s);
%      fprintf(s, 'Curve?');
%      readasync(s);
%      data = fread(s, 2500);
%      fclose(s);
%      
% 参考 : SERIAL/FOPEN, SERIAL/STOPASYNC.


% MP 12-30-99
% Copyright 1999-2004 The MathWorks, Inc. 
