% STOPASYNC   非同期読みこみと書き込みの停止
%
% STOPASYNC(OBJ) は、serial port オブジェクト OBJ と接続しているデバイス
% を使って、進行中の非同期読みこみや書き込み演算を停止します。OBJ は、
% serial port オブジェクトの配列です。 
%
% データは、関数 FPRINTF　や FWRITE を使って、非同期で書き込むことが
% できます。データは、関数 READASYNC を使って、ReadAsyncMode プロパティ
% を continuous に設定することで、非同期的に読み込むことができます。
% 非同期演算中は、プロパティ TransferStatus で示されます。
%
% 進行中の非同期演算を停止した後、TransferStatus プロパティは、idle に
% 設定され、出力バッファは新しくなり、ReadAsyncMode プロパティは、manual 
% に設定されます。
%
% 入力バッファの中のデータは、新しくなりません。このデータは、同期付きの
% 読み込み関数、たとえば、FREAD や FSCANF を使って、MATLAB ワークスペース
% に戻すことができます。
%
% OBJ が、serial port オブジェクトの配列で、オブジェクトの一つが停止する
% ことができない場合、配列の中の残りのオブジェクトは停止し、ワーニングが
% 表示されます。
%
% 例題:
%      s = serial('COM1');
%      fopen(s);
%      fprintf(s, 'Function:Shape Sin', 'async');
%      stopasync(s);
%      fclose(s);
%
% 参考 : SERIAL/READASYNC, SERIAL/FREAD, SERIAL/FSCANF, SERIAL/FGETL,
%        SERIAL/FGETS.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
