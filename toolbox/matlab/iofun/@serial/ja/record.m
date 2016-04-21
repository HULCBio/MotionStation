% RECORD   データとイベント情報をファイルに記録
%
% RECORD(OBJ) は、オブジェクト OBJ の RecordStatus プロパティを、on と
% off に切り替えます。RecordStatus が on の場合、デバイスにコマンドが
% 書き込まれ、デバイスからデータが読み込まれ、イベント情報が OBJ の
% RecordName プロパティで指定されたファイルに記録されます。RecordStatus
% が off の場合、情報は記録されません。OBJ は、1行1列の serial port 
% オブジェクトでなければなりません。デフォルトは、OBJの RecordStatus 
% は、off です。
%
% serial port オブジェクトは、RecordStatus が変更される前に、FOPEN 
% コマンドと共にデバイスに接続されなければなりません。接続された serial 
% port オブジェクトは、open の Status プロパティ値をもちます。
%
% 記録ファイルは、ASCII ファイルです。OBJ の RecordDetail プロパティは
% コンパクトに設計され、記録ファイルは、デバイスから読み込まれた値の数、
% デバイスに書き込まれている値の数、イベント情報が含まれます。OBJ の
% RecordDetail プロパティが、verbose に設定されている場合、記録ファイルは、
% デバイスから読み込まれた、またはデバイスに書き込まれたデータも含まれ
% ます。
%
% uchar, schar, (u)int8, (u)int16, (u)int32 の精度のバイナリデータは、
% 16進法で記録ファイルに記録されています。たとえば、255の int16 値は、
% 機器から読み込まれ、値 00FF が記録ファイルに記録されます。単精度、
% 倍精度でバイナリデータが、IEEE 754 浮動小数点ビット配列に従って、
% 記録されます。 
%
% RECORD(OBJ, 'STATE') は、RecordStatus プロパティ値に STATE を設定した
% オブジェクト OBJ を作ります。STATE は、'on'、または、'off'のどちらか
% です。
%
% オブジェクト RecordStatus プロパティ値は、オブジェクトが FLCLOSE コマ
% ンドをもつハードウェアからの接続が切れたとき、off に自動的に変わります。
%
% RecordName と RecordMode プロパティは、OBJが記録中のとき、読み込みのみ
% になります。これらのプロパティは、RECORD を使う前に、設定されていなければ
% なりません。
%
% 例題:
%       s = serial('COM1');
%       fopen(s)
%       set(s, 'RecordDetail', 'verbose')
%       record(s, 'on');
%       fprintf(s, '*IDN?')
%       fscanf(s);
%       fclose(s);
%       type record.txt
%
% 参考 : SERIAL/FOPEN, SERIAL/FCLOSE.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
