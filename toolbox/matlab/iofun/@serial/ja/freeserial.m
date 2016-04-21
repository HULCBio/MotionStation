% FREESERIAL   serial port 上のMATLABのホールドを解除
%
% FREESERIAL は、すべての Serial port 上の MATLAB のホールド状態を開放
% します。
%
% FREESERIAL('PORT') は、指定したポート PORT 上の MATLAB のホールド状態
% を開放します。PORT  は、文字列のセル配列です。
%
% FREESERIAL(OBJ) は、serial port オブジェクトに関連したポート上の 
% MATLABのホールド状態を開放します。OBJ は、serial port オブジェクトの
% 配列でも構いません。
%
% serial port オブジェクトが解放されたポートに接続しようとするときに、
% エラーが出力されます。FCLOSE コマンドは、serial port から serial port 
% オブジェクトを切断するために使用されます。
%
% serial port オブジェクトは、serial port と通信するために javax.comm
% パッケージを使用します。javax.comm パッケージのメモリリークによって、
% serial port オブジェクトは、MATLABを終了するか、FREESERIAL 関数が
% コールされるまでメモリから解放されません。
%
% serial port オブジェクトがポートに接続された後、別のアプリケーション
% から serial port オブジェクトに接続する必要があり、またMATLABを終了
% したくない場合のみ、FREESERIAL が使われます。
%
% 注意: この関数は、Windows プラットフォーム上でのみ使われます。
%
% 例題:
%      freeserial('COM1');
%      s = serial('COM1');
%      fopen(s);
%      fprintf(s, '*IDN?')
%      idn = fscanf(s);
%      fclose(s)
%      freeserial(s)
%   
% 参考 : INSTRUMENT/FCLOSE.


%    MP 4-11-00
%    Copyright 1999-2002 The MathWorks, Inc. 
