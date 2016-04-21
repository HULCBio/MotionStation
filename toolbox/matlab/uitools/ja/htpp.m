% HTPP   HTHELPに対するハイパーテキストのプリプロセッサ
% 
% STR = HTPP(CMD, LINK) は、HTHELP に対するHTML文字列(STR)を作成します。
% この関数は、ユーザが直接呼び出す関数ではありません。
%
% CMD の有効な文字列は、'main'、'contents'、'function' で、HTMLに変換
% されるテキストファイルのタイプを示します。
%
% HTPP または HTPP('main') は、メインのMATLABヘルプスクリーンに対する
% 文字列 HTML を作成します。
%
% HTPP('contents', LINK) は、文字列 LINK に含まれるトピックのContents.m
% ファイルに対するHTML文字列を作成します。
%
% HTPP('function', LINK) は、文字列 LINK に含まれるM-ファイルのヘルプ
% テキストに対するHTML文字列を作成します。
%
% HTHELP が、表示されているトピックスに関連するものにアクセスできるように、
% 適切なHTMLハイパーリンクが出力ファイルで設定されます。
%
% 参考：HTHELP, LOADHTML.
%
% この関数は古いもので、将来のバージョンでは削除される場合があります。


%   P. Barnard 12-28-94
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:08:15 $
