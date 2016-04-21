% RMDIR	  ディレクトリの削除
%
% [SUCCESS,MESSAGE,MESSAGEID] = RMDIR(DIRECTORY,MODE) は、親ディレクト
% リから DIRECTORY で指定されたアクセス権をもつディレクトリを削除しま
% す。RMDIR は、サブディレクトリを再帰的に削除することができます。
%
% [SUCCESS,MESSAGE,MESSAGEID] = RMDIR(DIRECTORY) は、DIRECTORY が空の
% ディレクトリである場合のみ、親ディレクトリから DIRECTORY を削除します。
%
% [SUCCESS,MESSAGE,MESSAGEID] = RMDIR(DIRECTORY, 's') は、親ディレクトリ
% からサブディレクトリツリーを含む DIRECTORY を削除します。注意 1 を
% 参照してください。

% 入力パラメータ:
%     DIRECTORY: 相対あるいは絶対パスで指定される文字列です。
%                注意 2 を参照してください。
%     MODE: 操作のモードを示すキャラクタのスカラです。
%           's' : DIRECTORY に含まれるサブディレクトリツリーが再帰的に
%                 削除されることを示します。注意 3 を参照してください。
%     
% 出力パラメータ:
%     SUCCESS: RMDIR の結果を定義する logical のスカラです。
%                 1 : RMDIR の実行に成功
%                 0 : エラーが発生
%     MESSAGE: エラーまたはワーニングメッセージを定義する文字列です。
%              空の文字列 : RMDIR の実行に成功
%              メッセージ : 適切なエラーまたはワーニングメッセージ
%     MESSAGEID: エラーまたはワーニング識別子を定義する文字列です。
%              空の文字列 : RMDIR の実行に成功
%              メッセージid : MATLABエラーまたはワーニングメッセージ識別子
%              (ERROR, LASTERR, WARNING, LASTWARNを参照)
%
% 注意 1: サブディレクトリツリーはファイルまたはサブディレクトリの書き
%         込み属性に関係なく削除されます。
% 注意 2: UNC パスがサポートされます。RMDIR は、正規表現のワイルドカード
%          * の使用をサポートしません。
% 注意 3: RMDIR は、Windows 98、または Millennium での 's' モードでの
%         削除をサポートしません。
%
% 参考 : CD, COPYFILE, DELETE, DIR, FILEATTRIB, MKDIR, MOVEFILE.


%   JP Barnard
%   Copyright 1984-2003 The MathWorks, Inc. 
