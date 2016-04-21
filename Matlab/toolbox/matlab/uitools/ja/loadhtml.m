% LOADHTML   HTHELPに対するHTMLのパーサ
% 
% LOADHTML(CMD,FN,LNK,TXT,FIG,AX,LH,COMP) は、HTMLのロード、文法解釈、
% HTHELPの表示を行います。この関数は、ユーザが直接呼び出す関数では
% ありません。
%
% CMD の有効な文字列は 'load' と 'loadstr' で、それぞれ、ファイル(FN)
% または与えられた文字列(TXT)から、HTMLのソースをロードします。LNK が空で
% なければ、LNK というセクションが表示されます。HTMLは、FIG で識別される
% ハンドルのfigureと、ハンドルが AX であるaxesに表示されます。LH は、
% 使用可能な種々のヘディングサイズに対するラインの高さのベクトルで、
% COMP は、ホストマシン名を含んでいます。
%
% TS = LOADHTML(CMD,FN,LNK,TXT,FIG,AX,LH,COMP)は、セクション LNK に
% 含まれているHTMLテキスト文字列を出力します。
%
% 参考：HTHELP, HTPP.
%
% この関数は廃止されており、将来のバージョンでは削除される場合があります。


%   P. Barnard 12-22-94
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:08:23 $
