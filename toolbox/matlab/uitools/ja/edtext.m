% EDTEXT   axesのtextオブジェクトの対話的編集
% 
% EDTEXT は、エディタブルテキストuicontrolをGCOの一番上に移動することに
% より視覚可能にし、string プロパティをGCOのプロパティに設定することで、
% GCO の string プロパティを編集します。uicontrolのコールバックがトリガ
% されていれば、GCOのstringプロパティは、ユーザが入力したものに設定されます。
%
% この関数を使って、axesのtextオブジェクトの文字列を編集するためには、
% axesのtextオブジェクトの buttondownfcn を 'edtext' に設定してください。
% 文字列を編集した後でコールバックを実行したい場合は、コールバック文字列を
% axesのtextオブジェクトの 'UserData' 内に設定してください。
%
% EDTEXT は、gcf内で、タグ 'edtext' をもつ視覚不可能のedit controlを
% 使用します。そのようなオブジェクトが見つからなければ、作成されます。
%
% EDTEXT('hide') は、エディタブルテキストオブジェクトを表示しません。
%
% 例題:
% 
% つぎの2つのコマンドは、カレントのfigure内のすべてのtextオブジェクト
% (title, xlabel, ylabel) の point-and-clock editing をインストールします。
% 
%     set(findall(gcf,'type','text'),'buttondownfcn','edtext')
%     set(gcf,'windowbuttondownfcn','edtext(''hide'')')
%   
% 参考： GCO, GCBO.


%  Author: T. Krauss, 10/94
%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:07:55 $
