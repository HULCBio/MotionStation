% FSEEK   ファイルの位置指示子の設定
% 
% STATUS = FSEEK(FID、OFFSET、ORIGIN) は、FID で指定されるファイル内
% のファイル位置指示子を、ORIGIN に対して指定された OFFSET バイトの位
% 置に移動します。
%
% FID は、FOPEN から得られる整数のファイル識別子です。
%
% OFFSET の値は、つぎのように解釈されます。
%     > 0    ファイルの終端方向へ移動
%     = 0    位置を変更しません
%     < 0    ファイルの先頭方向へ移動
%
% ORIGINの値は、つぎのように解釈されます。
%     'bof' または -1   ファイルの先頭
%     'cof' または  0   ファイル内のカレントの位置
%     'eof' または  1   ファイルの終端
%
% STATUS は、fseek 操作が成功すると0で、失敗ならば-1です。エラーが発生
% する場合は、より多くの情報を得るために、FERROR を使ってください。
%
% 例題:
%
%     fseek(fid,0,-1)
%
% は、ファイルをリワインドします。
%
% 参考：FOPEN, FTELL.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:13 $
%   Built-in function.

