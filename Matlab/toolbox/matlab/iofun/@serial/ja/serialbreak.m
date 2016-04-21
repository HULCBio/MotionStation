% SERIALBREAK   デバイスに break を送る
%
% SERIALBREAK(OBJ) オブジェクト OBJ に接続しているデバイスに、10ms の
% break を送ります。OBJ は、1行1列の serial port オブジェクトでなければ
% なりません。
%
% オブジェクト OBJ は、SERIALBREAK コマンドが呼び出される前に、 FOPEN 
% コマンドを使って、デバイスに接続しなければなりません。その他の場合は
% エラーになります。接続されたオブジェクトは、open の Status プロパティ
% 値をもちます。
%
% SERIALBREAK(OBJ, TIME) は、オブジェクト OBJ に接続しているデバイスに 
% TIME ms の break を送ります。
%
% SERIALBREAK は、実行が完了するまで、MATLAB のコマンドラインを停止する
% 同期を取る関数です。
%
% SERIALBREAK は、非同期の書き込みの実行中に、コールされると、エラーを
% 戻します。この場合、関数 STOPASYNC をコールして、非同期書き込み演算を
% 停止し、書き込み演算が完了するまで、待ち状態にすることができます。
%
% 切断の時間間隔は、いくつかのオペレーティングシステムでは不正確になる
% 可能性があることに注意してください。
%
% 例題:
%      s = serial('COM1');
%      fopen(s);
%      serialbreak(s);
%      serialbreak(s, 50);
%      fclose(s);
%
% 参考 : SERIAL/FOPEN, SERIAL/STOPASYNC.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
