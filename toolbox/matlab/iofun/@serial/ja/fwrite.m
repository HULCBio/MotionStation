% FWRITE   バイナリデータをデバイスに書き込み
%
% FWRITE(OBJ, A) は、データ A を serial port オブジェクト OBJ に接続
% しているデバイスに書き込みます。
%
% serial port オブジェクトは、任意のデータがデバイスに書き込まれる前に
% 関数 FOPEN を使ってデバイスに接続されていなければなりません。他の場合、
% エラーが出力されます。接続された serial port オブジェクトは、open の
% Status プロパティをもちます。
%
% FWRITE(OBJ,A,'PRECISION') は、指定した精度 PRECISION でバイナリデータ
% をMATLAB 値に変換して書き込みます。サポートされる PRECISION 文字列は、
% 以下で定義されます。デフォルトは、'uchar' の PRECISION が使われます。
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
% FWRITE(OBJ, A, 'MODE')
% FWRITE(OBJ, A, 'PRECISION', 'MODE') は、MODE が、'async' の場合、
% デバイスに非同期でデータを書き込み、MODE が 'sync' の場合、同期を
% とってデバイスにデータを書き込みます。デフォルトで、データは、'sync'
% MODE で書き込まれ、このことは、指定したデータが、デバイスに書かれて
% いたり、タイムアウトが生じていた後、コントロールがMATLAB に戻ることを
% 意味します。'async' MODE が使用される場合、コントロールは FWRITE  
% コマンドが実行されたあと、すぐに、MATLAB に戻ります。
%
% デバイスのバイト順は、OBJ の ByteOrder プロパティで指定することが
% できます。
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
%      fwrite(s, [0 5 5 0 5 5 0]);
%      fclose(s);
%
% 参考 : SERIAL/FOPEN, SERIAL/FPRINTF, SERIAL/RECORD.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
