% FPRINTF   デバイスにテキストを書き込む
%
% FPRINTF(OBJ,'CMD') は、serial port オブジェクト OBJ に接続されている
% デバイスに文字列 CMD を書き込みます。OBJ は、1行1列の serial port 
% オブジェクトでなければなりません。
%
% serial port オブジェクトは、任意のデータがデバイスに書き込まれる前に
% 関数 FOPEN を使ってデバイスに接続されていなければなりません。他の場合、
% エラーが出力されます。接続された serial port オブジェクトは、open の
% Status プロパティをもちます。
%
% FPRINTF(OBJ,'FORMAT','CMD') は、serial port オブジェクト OBJ に接続
% されたデバイスに、フォーマット FORMAT を使って、文字列 CMD を書き込み
% ます。デフォルトで、%s\n の FORMAT 文字列が使用されます。SPRINTF 関数
% は、機器に書き込まれたフォーマットデータを使用します。
% 
% CMD 内の \n の出現の度に、OBJ の Terminator プロパティ値が置き換え
% られます。デフォルト FORMAT %s\n を使う場合、デバイスに記述された
% すべてのコマンドが、Terminator 値を最後につけます。
%
% FORMAT は、C 言語変換子を含む文字列です。変換設定子は、キャラクタ % 、
% オプションフラグ、オプション幅、精度のフィールド、オプションサブタイプ
% 設定子、変換キャラクタ d, i, o, u, x, X, f, e, E, g, G, c, s を含みま
% す。すべての詳細については、SPRINTF ファイルの I/O フォーマット指定、
% または C マニュアルを参照してください。
%
% FPRINTF(OBJ, 'CMD', 'MODE')
% FPRINTF(OBJ, 'FORMAT', 'CMD', 'MODE') は、MODE が、'async' の場合、
% デバイスに非同期でデータを書き込み、MODE が 'sync' の場合、同期を
% とってデバイスにデータを書き込みます。デフォルトで、データは、'sync'
% MODE で書き込まれ、このことは、指定したデータが、デバイスに書かれて
% いたり、タイムアウトが生じていた後、コントロールがMATLAB に戻ることを
% 意味します。'async' MODE が使用される場合、コントロールは FPRINTF 
% コマンドが実行されたあと、すぐに、MATLAB に戻ります。
%
% OBJ の TransferStatus プロパティは、非同期書き込みが進行中か否かを
% 示します。
%
% OBJ の ValuesSent プロパティは、デバイスに記述される値の数で更新
% されます。
%
% OBJ の RecordStatus プロパティが、RECORD コマンドにより on に
% 設定されている場合、デバイスに記述されたデータは、OBJ の RecordName 
% プロパティ値に指定されたファイル内に記録されます。
%
% 例題:
%      s = serial('COM1');
%      fopen(s);
%      fprintf(s, 'Freq 2000');
%      fclose(s);
%      delete(s);
%
% 参考 : SERIAL/FOPEN, SERIAL/FWRITE, SERIAL/STOPASYNC, SERIAL/RECORD,
%        SPRINTF.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
