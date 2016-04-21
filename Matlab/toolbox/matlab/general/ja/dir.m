% DIR   ディレクトリのリスト
% 
% DIR directory_nameは、ディレクトリ内のファイルをリストします。パス名と
% ワイルドカードを使うことができます。たとえば、DIR *.mは、カレントディ
% レクトリのすべてのM-ファイルをリストします。
%
% D = DIR('directory_name')は、つぎのフィールドをもつM行1列の構造体とし
% て結果を出力します。
%     name  -- ファイル名
%     date  -- ファイルを修正した最新日
%     bytes - ファイルへの割り当てバイト数
%     isdir - nameがディレクトリの場合1、そうでなければ0
%
% 参考：WHAT, CD, TYPE, DELETE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:53:00 $
%   Built-in function.
