% XSLT   XSLTエンジンを使ってXMLドキュメントを変換
%
% RESULT = XSLT(SOURCE,STYLE,DEST) は、スタイルシートを使ってXML
% ドキュメントを変換し、結果のドキュメントのURLを出力します。関数は、
% 以下の入力を使い、最初のものは必須です。
%   SOURCE は、ソースXMLファイルのファイル名またはURLです。SOURCE は、
%     DOM nodeでもかまいません。
%   STYLE は、XSLスタイルシートのファイル名またはURLです。
%   DEST は、希望する出力ドキュメントのファイル名またはURLです。
%     DEST が未指定または空の場合は、関数はテンポラリファイル名を利用
%     します。DEST が'-tostring' の場合は、出力ドキュメントは、MATLAB
%     文字列として出力されます。
%
% [RESULT,STYLE] = XSLT(...) は、後に続くXLSRの呼び出しに渡すために適し
% た処理済のスタイルシートをSTYLEとして出力します。これにより、スタイル
% シートの処理の重複を避けることができます。
%
% XSLT(...,'-web') は、結果のドキュメントをヘルプブラウザに表示します。
%
% 例題:
% 以下は、スタイルシート "info.xsl"を使ってファイル"info.xml" をテンポ
% ラリファイルに変換し、結果をヘルプブラウザに表示します。MATLABは、
% Launch Padで利用される複数のinfo.xmlファイルを含みます。
%
%   xslt info.xml info.xsl -web
%    
% 参考 ： XMLREAD, XMLWRITE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 01:58:39 $
