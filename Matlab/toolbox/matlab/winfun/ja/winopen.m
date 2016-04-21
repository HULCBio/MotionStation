% WINOPEN   Microsoft Windows コマンドを用いてファイルまたはディレクトリを開く
% WINOPEN FILENAME は、適切なMicrosoft Windowsシェルコマンドを使って、ファイル
% タイプおよび拡張子に基づきファイルまたはディレクトリFILENAMEを開きます。
% この関数は、Windows エクスプローラの中のファイルまたはディレクトリをダブルク
% リックしたように、
%
% 例題:
%
%   Microsoft Word がインストールされているとき、
%   winopen('c:\myinfo.doc')
%   は、ファイルが存在する場合はMicrosoft Word でそのファイルを開き、存在しな
%   い場合はエラーになります。
%
%   winopen('c:\')
%   は、新規のWindowsエクスプローラウィンドウを開き、Cドライブの内容を表示します。
%   
% 参考:  OPEN, DOS, WEB.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/04/28 02:09:55 $
