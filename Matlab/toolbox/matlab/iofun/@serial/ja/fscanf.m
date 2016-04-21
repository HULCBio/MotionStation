% FSCANF   デバイスとフォーマット付きテキストからデータを読み込み
%
% A=FSCANF(OBJ) は、serial port オブジェクト OBJ に接続しているデバイス
% からデータを読み込み、フォーマット付きのテキストデータとして A に出力
% します。
%
% FSCANF は、つぎの事柄の内の一つが生じるとブロックされます。:
%     1. Terminator プロパティで指定された終端子を受け取る
%     2. Timeout プロパティで指定された時間切れが発生する
%     3. 入力バッファがいっぱいになる
%
% serial port オブジェクト OBJ は、任意のデータがデバイスから読み込まれる
% 前に FOPEN 関数を使ってデバイスに接続していなければなりません。その他の
% 場合は、エラーが出力されます。接続された serial port オブジェクトは、
% open の Status プロパティ値をもっています。
%
% A=FSCANF(OBJ,'FORMAT') は、serial port オブジェクト OBJ に接続して
% いるデバイスからデータを読み込み、指定した FORMAT 文字列に従って、
% 変換します。デフォルトでは、%c FORMAT 文字列が使われます。SSCANF 関数
% を使ってデバイスから読み込んだデータをフォーマットします。
%
% FORMAT は、C 言語変換子を含む文字列です。変換設定子は、キャラクタ % 、
% オプションフラグ、オプション幅、精度のフィールド、オプションサブタイプ
% 設定子、変換キャラクタ d, i, o, u, x, X, f, e, E, g, G, c, s を含みま
% す。すべての詳細については、SPRINTF ファイルの I/O フォーマット指定、
% または C マニュアルを参照してください。
%
% A=FSCANF(OBJ,'FORMAT',SIZE) は、serial port オブジェクト OBJ に接続
% されたデバイスから指定された値の数 SIZE を読み込みます。
%
% FSCANF は、つぎの事柄の内の一つが生じるとブロックされます。:
%     1. Terminator プロパティで指定された終端子を受け取る
%     2. Timeout プロパティで指定された時間切れが発生する
%     3. SIZE の値が受け取られた
%
% SIZE の利用可能なオプションは以下の通りです。:
%
%    N      列ベクトル内で、最高で N 値まで読み込む
%    [M,N]  列の順に、M 行 N 列の行列を満たすように最高 M*N 要素まで
%           データを読み込む
%
% SIZE をINF に設定することはできません。SIZE が、OBJ の InputBufferSize 
% プロパティ値より大きい場合、エラーが生じます。SIZE は、値で設定し、
% 一方、InputBufferSize は、バイトで設定することに注意してください。
%
% 行列 A が、キャラクタ変換のみの使用の結果で、SIZE が、[M,N]の型をして
% いない場合、行ベクトルが出力されます。
%
% [A,COUNT]=FSCANF(OBJ,...) は、読み込んだ値の数を COUNT に出力します。
%
% [A,COUNT,MSG]=FSCANF(OBJ,...) は、FSCANF が完全にうまく機能しない場合、
% メッセージ MSG を出力します。MSG が指定されていない場合、ワーニングが
% コマンドラインに表示されます。
%
% OBJ の ValuesReceived プロパティは、デバイスから読み込まれる
% 値の数で更新されます。
% 
% OBJ の RecordStatus プロパティは、関数 RECORD で on に設定されている
% 場合、データは、OBJ の RecordName プロパティ値に指定されたファイル内
% に記録されます。
%    
% 例題:
%       s = serial('COM1');
%       fopen(s);
%       fprintf(s, '*IDN?');
%       idn = fscanf(s);
%       fclose(s);
%       delete(s);
%
% 参考 : SERIAL/FOPEN, SERIAL/FREAD, SERIAL/RECORD, STRREAD, SSCANF.


%    Copyright 1999-2004 The MathWorks, Inc. 
