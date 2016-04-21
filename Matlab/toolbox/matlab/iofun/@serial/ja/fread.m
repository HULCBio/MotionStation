% FREAD   デバイスからバイナリデータを読み込み
% 
% A=FREAD(OBJ,SIZE) は、serial port オブジェクト OBJ に接続しているデバイス
% から、少なくとも指定された値の数 SIZE を読み込み、A に出力します。
%
% FREAD は、つぎの事柄の内の一つが生じるまで、ブロックします。:
%     1. SIZE の値が受け取られた
%     2. Timeout プロパティで指定された時間切れが発生する
%
% serial port オブジェクト OBJ は、任意のデータがデバイスから読み込まれる
% 前に FOPEN 関数を使ってデバイスに接続していなければなりません。その他の
% 場合は、エラーが出力されます。接続された serial port オブジェクトは、
% open の Status プロパティ値をもっています。
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
% A=FREAD(OBJ,SIZE,'PRECISION') は、指定した精度 PRECISION でバイナリ
% データを読み込みます。精度に関する引数は、各値のビット数をコントロール
% し、これらのビットをキャラクタ、整数、浮動小数点のいずれかとして解釈
% します。サポートされている PRECISION 文字列は、以下ので定義されます。
% デフォルトは、'uchar' の PRECISION が使われます。デフォルトで、数値は、
% 倍精度配列で出力されます。
%   
%    MATLAB           記述
%    'uchar'          符号なしキャラクタ   8 bits.
%    'schar'          符号付きキャラクタ   8 bits.
%    'int8'           整数                 8 bits.
%    'int16'          整数                 16 bits.
%    'int32'          整数                 32 bits.
%    'uint8'          符号なし整数         8 bits.
%    'uint16'         符号なし整数         16 bits.
%    'uint32'         符号なし整数         32 bits.
%    'single'         浮動小数点           32 bits.
%    'float32'        浮動小数点           32 bits.
%    'double'         浮動小数点           64 bits.
%    'float64'        浮動小数点           64 bits.
%    'char'           キャラクタ           8 bits 
%                                          (符号付き、または、符号なし)
%    'short'          整数                 16 bits.
%    'int'            整数                 32 bits.
%    'long'           整数                 32 または 64 bits.
%    'ushort'         符号なし整数         16 bits.
%    'uint'           符号なし整数         32 bits.
%    'ulong'          符号なし整数         32 bits または 64 bits.
%    'float'          浮動小数点           32 bits.
%
% [A,COUNT]=FREAD(OBJ,...) は、読み込んだ値の数を COUNT に出力します。
%
% [A,COUNT,MSG]=FREAD(OBJ,...) は、FREAD が完全にうまく機能しない場合、
% メッセージ MSG を出力します。MSG が指定されていない場合、ワーニングが
% コマンドラインに表示されます。
%
% デバイスのバイト順は、OBJ の ByteOrder プロパティで指定することが
% できます。
%
% OBJ の ValuesReceived プロパティは、デバイスから読み込まれる
% 値の数で更新されます。
% 
% OBJ の RecordStatus プロパティは、関数 RECORD で on に設定されている
% 場合、データは、OBJ の RecordName プロパティ値に指定されたファイル内
% に記録されます。
%
% 例題:
%      s = serial('COM1');
%      fopen(s);
%      fprintf(s, 'Curve?');
%      data = fread(s, 512);
%      fclose(s);
%
% 参考 : SERIAL/FOPEN, SERIAL/FSCANF, SERIAL/FGETS, SERIAL/FGETL,
%        SERIAL/RECORD.
%


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
