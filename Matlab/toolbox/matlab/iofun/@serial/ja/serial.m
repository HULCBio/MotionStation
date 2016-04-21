% SERIAL   serial port オブジェクトの作成
%
% S = SERIAL('PORT') は、ポート PORT に関連した serial port オブジェクトを
% 作成します。PORT が、存在してなかったり、使用中の場合、serial port オブ
% ジェクトをデバイスに接続することはできません。
%
% デバイスとの通信を行うために、オブジェクトは、関数 FOPEN を使って、
% serial port に接続する必要があります。
%
% serial port オブジェクトが作成されると、オブジェクトの Status プロパ
% ティがクローズします。オブジェクトが関数 FOPEN を使って、serial port 
% に接続されると、Status プロパティは、open に設定されます。一つの 
% serial port オブジェクトは、一度に、一つの serial port のみに接続する
% ことができます。
%
% S = SERIAL('PORT','P1',V1,'P2',V2,...) は、ポート PORT に関連した 
% serial port オブジェクトを作成します。そして、その中には、指定した
% プロパティ値を含んでいます。不適切なプロパティ名、または、プロパティ値
% が指定されている場合、オブジェクトは作成されません。
%
% プロパティ名と値の組は、関数 SET でサポートされている任意のフォーマット
% で記述できることに注意してください。たとえば、パラメータ-値の文字列の
% 組、構造体、セル配列等です。
%
% 例題:
%       % serial port オブジェクの作成:
%         s1 = serial('COM1');
%         s2 = serial('COM2', 'BaudRate', 1200);
%
%       % serial port オブジェクトを Serial port に接続:
%         fopen(s1)
%         fopen(s2)	
%
%       % デバイスの読み込み
%         fprintf(s1, '*IDN?');
%         idn = fscanf(s1);
%
%       % serial port から serial port オブジェクトを切断
%         fclose(s1); 
%         fclose(s2);
%
% 参考 : SERIAL/FOPEN.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
