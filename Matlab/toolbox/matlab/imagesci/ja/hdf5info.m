%HDF5INFO HDF5 ファイルについて情報を取得します
%   
% FILEINFO = HDF5INFO(FILENAME) は、HDF5 ファイルの内容についての情報
% を含むフィールドをもつ構造体を出力します。FILENAME は、HDF ファイル
% の名前を指定する文字列です。
% 
% FILEINFO = HDF5INFO(..., 'ReadAttributes', BOOL) により、HDF5 
% ファイルの属性の値を読み込むかどうかを指定することが可能です。
% BOOL のデフォルト値は、true です。
%
% 参考 HDF5READ, HDF5WRITE, HDF5COPYRIGHT.TXT.

%   binky
%   Copyright 1984-2002 The MathWorks, Inc. 
