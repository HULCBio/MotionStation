% FTELL   ファイルの位置指示子の取得
% 
% POSITION = FTELL(FID) は、指定したファイルの位置指示子の位置を出力し
% ます。位置は、ファイルの先頭からのバイト数で指定されます。-1が出力される
% 場合は、失敗したことを示しています。エラーの性質についての情報を得るため
% には、FERRORを使ってください。
%
% FID は、FOPEN から得られる整数のファイル識別子です。
%
% 参考：FOPEN, FSEEK.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:14 $
%   Built-in function.
