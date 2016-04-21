% HTHELP  MATLABのヘルプとHTML表示のためのハイパーテキストヘルプ
%         ユーティリティ
% 
% FIG = HTHELP(FN) は、ハイパーテキストヘルプウィンドウを作成し、指定した
% ファイル(FN)をロードします。FN は、toolbox名、MATLABのm-ファイル名、
% HTMLソースファイル名のようなMATLABトピックで構いません。ソースファイル
% の書式は、HTML書式を拡張したサブセットです。HTHELP は、テキストを表示し
% 他のHTMLドキュメントや、表示中のドキュメントの他の部分へのハイパーリンク
% を設定します。
% 
% HTHELP 自身では、トピックへの適切なリンクをもつ、トップレベルのMATLAB
% ヘルプスクリーンを表示します。
%
% HTHELP('topic') は、m-ファイルへの適切なリンクをもつ、'topic' に対する
% Contentsファイルを表示します。
%
% HTHELP('m-file') は、関連するm-ファイルへの適切なリンクをもつ、'm-file'
% に対するヘルプを表示します。
%
% HTHELP('HTML file name') は、指定したHTMLソースファイルをHTHELPビューワ
% ウィンドウにロードします。
%
% 詳細は、hthelp('hthelp') を実行してみてください。
%
% この関数は古いもので、将来のバージョンでは削除される場合があります。


%   Paul Parker 7-12-94
%   Revised P. Barnard 12-28-94
%   Revised J. Wu 11-01-96
%   Revised K. Critz 6-18-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:08:14 $
