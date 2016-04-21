% MKDIR   新規ディレクトリの作成
%
% [SUCCESS,MESSAGE,MESSAGEID] = MKDIR(PARENTDIR,NEWDIR) は、親の 
% PARENTDIR の下に、新規ディレクトリを NEWDIR として作成します。
% PARENTDIR が絶対パスとして指定されてる間は、NEWDIR は、相対パス
% でなければなりません。NEWDIR が存在する場合、MKDIR は、SUCCESS = 1
% を出力し、ユーザに既にディレクトリが存在するというワーニングを出し
% ます。
% 
% [SUCCESS,MESSAGE,MESSAGEID] = MKDIR(NEWDIR) は、NEWDIR が相対パスを
% 表わす場合、カレントディレクトリ内に、ディレクトリ NEWDIR を作成します。
% そうでない場合、NEWDIR は、絶対パスを表わし、MKDIR は、カレントボリューム
% のルートに絶対ディレクトリ NEWDIR を作成しようと試みます。絶対パスは、
% Windows ドライブの文字、UNC パス '\\' 文字列、または、 UNIX '/' 文字の
% いずれかではじまります。
% [SUCCESS,MESSAGE,MESSAGEID] = MKDIR(NEWDIR) は、カレントディレクトリ
% 内に、ディレクトリ NEWDIR を作成します。
%
% [SUCCESS,MESSAGE,MESSAGEID] = MKDIR(PARENTDIR,NEWDIR) は、存在する
% ディレクトリ PARENTDIR に、ディレクトリ NEWDIR を作成します。
%
% 入力パラメータ:
%     PARENTDIR : 親ディレクトリで指定される文字列です。注意 1 を
%                 参照してください。
%     NEWDIR : 新規ディレクトリとして指定される文字列です。
%
% 出力パラメータ:
%     SUCCESS : MKDIR の結果を定義する logical のスカラです。
%              1 : MKDIR は実行に成功
%              0 : エラーが発生
%     MESSAGE : エラーまたはワーニングメッセージを定義する文字列です。
%               空の文字列 : MKDIR は実行に成功
%               メッセージ : 適切なエラーまたはワーニングメッセージ
%     MESSAGEID : エラーまたはワーニングの識別子を定義する文字列です。
%                 空の文字列 : MKDIR は実行に成功
%                 メッセージ : 適切なエラーまたはワーニングの識別子
%                 (ERROR, LASTERR, WARNING, LASTWARN を参照)
%
% 注意 1: UNC パスがサポートされています。
% 
% 参考：CD, COPYFILE, DELETE, DIR, FILEATTRIB, MOVEFILE, RMDIR.



%   JP Barnard
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $ $Date: 2004/04/28 01:53:23 $
