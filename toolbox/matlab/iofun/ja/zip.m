% ZIP     zipファイルの作成
%
% ZIP(ZIPFILE,FILES) は、文字列または文字列からなるセル配列である FILES
% に指定したファイルのリストから、ZIPFILE という名前のzipファイルを
% 作成します。FILES 内で指定されたパスは、カレントディレクトリの相対パス
% か、絶対パスのいずれかでなければなりません。ディレクトリは、再帰的に
% 他の内容のすべてを含みます。
%
% ZIP(ZIPFILE,FILES,ROOTDIR) は、カレントディレクトリではなく、ROOTDIR 
% に関して FILES に対するパスが指定されることが可能になります。
% 
% 参考 ： UNZIP.


% Matthew J. Simoneau, 15-Nov-2001
% Copyright 1984-2004 The MathWorks, Inc.