% FGETS   終端子を保持したままデバイスからテキストの1行を読み込み
%
% TLINE=FGETS(OBJ) は、serial port オブジェクト OBJ に接続している
% デバイスからテキストの1行を読み込み、TLINE に出力します。出力データは、
% テキストのラインに終端子を含みます。終端子を除くには、FGETL を使用して
% ください。
%    
% FGETS は、つぎの事柄の内の一つが生じるとブロックされます。:
%     1. Terminator プロパティで指定された終端子を受け取る
%     2. Timeout プロパティで指定された時間切れが発生する
%     3. 入力バッファがいっぱいになる
%
% serial port オブジェクト OBJ は、任意のデータがデバイスから読み込まれる
% 前に FOPEN 関数を使ってデバイスに接続していなければなりません。その他の
% 場合は、エラーが出力されます。接続された serial port オブジェクトは、
% open の Status プロパティ値をもっています。
%
% [TLINE,COUNT]=FGETS(OBJ) は、COUNT に読み込んだ値の番号を出力します。
% COUNT は、終端子を含みます。
%
% [TLINE,COUNT,MSG]=FGETS(OBJ) は、FGETS が完全にうまく機能しない場合、
% メッセージ MSG を出力します。MSG が指定されていない場合、ワーニングが
% コマンドラインに表示されます。
%
% OBJ の ValuesReceived プロパティは、終端子が含まれる、デバイスから
% 読み込まれた値の番号によって更新されます。
%
% OBJ の RecordStatus property は、RECORD 関数で on に設定されている
% 場合、データを受け取った TLINE は、OBJ の RecordName プロパティ値に
% 指定されたファイル内に記録されます。
% 
% 例題:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, '*IDN?');
%       idn = fgets(s);
%       fclose(s);
%       delete(s);
%
% 参考 : SERIAL/FGETL, SERIAL/FOPEN, SERIAL/RECORD.



% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
