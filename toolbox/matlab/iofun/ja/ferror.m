% FERROR   エラーの状態の表示
% 
% MESSAGE = FERROR(FID) は、指定したファイルに関して最後に行われたファイル
% I/O操作に関するエラーメッセージを出力します。FID は、FOPEN から得られる
% 整数のファイル識別子であるか、または標準入力ならば0、標準出力ならば1、
% 標準エラーならば2のいずれかです。
%
% [MESSAGE,ERRNUM] = FERROR(FID) は、同様にエラー番号を出力します。
% 最後に行われたI/O操作が成功した場合は、MESSAGE は空で、ERRNUM は
% 0です。非ゼロの ERRNUM は、エラーが発生したことを示します。ERRNUM の
% 値は、操作しているプラットフォーム上のCライブラリにより出力される値と
% 一致します。
%
% [...] = FERROR(FID,'clear')vは、指定したファイルに対するエラー指示子を
% 消去します。
%
% 参考：FOPEN, FCLOSE, FREAD, FWRITE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:03 $
%   Built-in function.
