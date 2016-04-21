% DDEEXEC 実行のための文字列を転送
% 
% DDEEXECは、確立されたDDE通信によって、他のアプリケーションに実行する
% ための文字列を転送します。文字列は、引数commandとして指定します。
%
% rc = DDEEXEC(channel,command,item,timeout)
%
% rc      返り値: 0は失敗、1は成功を意味します。
% channel DDEINITからの通信チャンネル
% command 実行されるコマンドを指定する文字列
% item    (オプション的に)実行のためのDDEアイテムを指定する文字列。この
%         引数は、多くのアプリケーションでは使用されません。アプリケー
%         ションでもの引数が必要な場合、commandについての追加情報を与え
%         ます。詳細は、サーバドキュメントを参照してください。
% timeout (オプション的に)オペレーションの制限時間を指定するスカラ値。
%         timeoutは、1000分の1秒単位で指定します。timeoutのデフォルト値
%         は、3秒です。
%
% たとえば、通信に割り当てられたチャンネルを与え、コマンドをExcelに転送
% します。
% 
%    rc = ddeexec(channel、'[formula.goto("r1c1")]');
% 
% 参考：DDEINIT, DDETERM, DDEREQ, DDEPOKE, DDEADV, DDEUNADV.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:09:42 $
%   Built-in function.
