% FCLOSE   デバイスから serial port オブジェクトの切断
%
% FCLOSE(OBJ) は、デバイスから serial port オブジェクト OBJ を切断します。
% OBJ は、serial port オブジェクトの配列です。
%
% OBJ がデバイスからうまく切断された場合、OBJ の Status プロパティは、
% closed に設定され、RecordStatus プロパティは、off に設定されます。
% OBJ は、関数 FOPEN を使って、デバイスに再結合されます。
%
% データがデバイスに非同期的に書き込まれている間、オブジェクトを切断する
% ことはできません。STOPASYNC 関数は、非同期的な書き込みを中止するために
% 使われます。
%
% OBJ は、serial port オブジェクトの配列で、オブジェクトの一つがデバイス
% から切断できない場合、配列内の残りのオブジェクトは、デバイスから切断
% され、ワーニングを表示します。
%
% 例題:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, '*IDN?');
%       idn = fscanf(s);
%       fclose(s);
%
% 参考 : SERIAL/FOPEN, SERIAL/STOPASYNC.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
