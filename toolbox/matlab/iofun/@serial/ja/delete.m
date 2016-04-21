% DELETE   メモリから serial port オブジェクトを削除
%
% DELETE(OBJ) は、serial port オブジェクト OBJ を削除します。OBJ は、
% 削除されたり、CLEAR でワークスペースから消去されると、無効なオブジェクト
% になり、デバイスに再接続できません。
%
% serial port オブジェクトへの複数のリファレンスが、ワークスペースの中に
% 存在する場合、一つのSerial port オブジェクトを削除すると、残りの
% リファレンスが無効になります。これらの残りのリファレンスは、CLEAR 
% コマンドを使って、ワークスペースからクリアしてください。
%
% 例えば open の Status プロパティ値をもつようなデバイスに接続している 
% serial port オブジェクトを削除した場合、エラーを出力します。serial 
% port オブジェクトは、FCLOSE 関数を使ってデバイスから切り離すことが
% できます。
% 
% データがデバイスに非同期で書き込まれている間に serial port オブジェクト
% を削除した場合、エラーを出力します。STOPASYNC 関数は非同期の書き込みを
% 中止するために使われます。
% 
% OBJ が serial port オブジェクトの配列で、オブジェクトの一つが削除
% できない場合、配列内の残りのオブジェクトは削除され、ワーニングが表示
% されます。
%
% DELETE は、serial port session の最後に使うものです。
%
%    See also SERIAL/FCLOSE, SERIAL/STOPASYNC, SERIAL/ISVALID.
%


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
