% FOPEN   serial port オブジェクトをデバイスと接続
%
% FOPEN(OBJ) は、serial port オブジェクト OBJ をデバイスと接続します。
% OBJ は、serial port オブジェクトの配列です。
%
% 同じコンフィギュレーションをもつ serial port オブジェクトのみが、同時に
% 機器に接続されます。例えば、一つのserial port オブジェクトのみが、COM2
% ポートに同時に接続できます。OBJ がうまくデバイスに接続できた場合、OBJ 
% の Status プロパティは open に設定され、他の場合、Status プロパティは
% closed に設定されたままです。
%
% OBJ がオープンされると、入力バッファと出力バッファ内に残っているデータは
% フラッシュされ、BytesAvailable, BytesToOutput, ValuesReceived, ValuesSent 
% プロパティはゼロに設定されます。
%
% いくつかのプロパティ値は、デバイスに接続された後に確認だけ行えます。
% 例題には BaudRate, FlowControl, Parity が含まれます。これらのプロパティ
% のいくつかは、デバイスでサポートされていない値を設定すると、エラーが
% 出力され、オブジェクトはデバイスと接続されません。
%
% いくつかのプロパティは、serial port オブジェクトがオープン(接続)して
% いる間は読み込み専用になり、FOPENを使用する前に設定されていなければ
% なりません。例題は、InputBufferSize と OutputBufferSize が含まれます。
%
% FOPEN が、Open の Status プロパティ値をもつ serial port オブジェクト
% をコールした場合、エラーが返されます。
%
% デバイスのバイトの順番は、OBJ の ByteOrder プロパティで設定することが
% できます。
%
% OBJ が serial port オブジェクトの配列で、デバイスと接続できない
% オブジェクトの一つである場合、配列内の残りのオブジェクトは、デバイス
% に接続され、ワーニングが表示されます。
%
% 例題:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, '*IDN?');
%       idn = fscanf(s);
%       fclose(s);
%
% 参考 : SERIAL/FCLOSE.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
