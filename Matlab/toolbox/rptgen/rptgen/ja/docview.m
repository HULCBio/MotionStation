% DOCVIEW   RTF/DOCビューワをオープン
% DOCVIEW(FILENAME)は、ファイルFILENAMEに対して、RTF/DOCファイルビューワ
% を起動します。
%
% [STATUS,MESSAGE]=DOCVIEW(FILENAME)の書式で呼び出される場合、STATUSはフ
% ァイルビューワが正常に起動された場合は1を出力します。ビューワが起動さ
% れなかった場合は、DOCVIEWはSTATUSに0を出力し、MESSAGEにエラーの記述を
% 出力します。
%
% コンピュータがMicrosoft Wordをインストールしている PCである場合は、以
% 下のコマンドで、DOCVIEW(FILENAME,COMMAND1,COMMAND2)の形式で呼び出され
% ます。
%  
%     'UpdateFields' - ドキュメント内のフィールドを更新
%      'PrintDoc'     - ドキュメントをプリント
%      'CloseApp'     - 全ての他のコマンドを実行した後でWordをクローズ
%   
% ファイルビューワを動作させるためには、このm-ファイルを設定する必要があ
% る場合があります。このファイルの62行目の説明を参照してください。
%
% 参考   RPTVIEWFILE, DOCOPT, WEB
%





%   Copyright (c) 1997-2001 by The MathWorks, Inc. All Rights Reserved.
