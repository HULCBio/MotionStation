% DDEREQ アプリケーションからのデータの要求
% 
% DDEREQは、DDE通信によってサーバアプリケーションからデータを要求します。
% DDEREQは、要求されたデータを含む行列を出力するか、失敗したなら空行列を
% 出力します。
%
% data = DDEREQ(channel,item,format,timeout)
%
% data    要求されたデータを含む行列。失敗の場合は、空行列になります。
% channel DDEINITからの通信チャンネル
% item    要求されたデータに対するサーバアプリケーションのDDEアイテム名
%         を指定する文字列。
% format  (オプション的に)要求されたデータの書式を指定する2要素の配列。
%         1番目の要素は、使用するWindowsクリップボードの書式を指定します。
%         現在は、CF_TEXTのみサポートされていて、値1に対応します。2番目
%         の要素は、結果の行列タイプを指定する配列です。有効なタイプは、
%         NUMERIC(デフォルトで、値0に対応)と、STRING(値1に相当)です。デ
%         フォルトフォーマットは、[1 0]です。
% timeout (オプション的に)オペレーションの制限時間を指定するスカラ値。制
%         限時間は、1000分の1秒単位で指定します。デフォルト値は、3秒です。
%
% たとえば、Excelから、セルの行列を要求します。
% 
%       mymtx = ddereq(channel, 'r1c1:r10c10');
%
% 参考：DDEINIT, DDETERM, DDEEXEC, DDEPOKE, DDEADV, DDEUNADV.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 02:09:45 $
%   Built-in function.
