% GTEXT   マウスを使ってテキストを配置
% 
% GTEXT('string') は、グラフウィンドウを表示し、クロスヘアを作成して、マウス
% ボタンまたはキーボードのキー入力を待ちます。クロスヘアは、マウス(または、
% コンピュータによっては矢印キーになります)を使って位置を決定します。
% マウスボタンまたは任意のキーを押すと、グラフの選択した位置にテキスト
% 文字列を書き出します。
%
% GTEXT(C) は、文字列 C のセル配列の各行で定義された複数行の文字列を配
% 置します。
%
% GTEXT(...,'PropertyName','PropertyValue,...) は、指定したテキスト
% プロパティの値を設定します。複数のプロパティ値でも、1つのステート
% メントで設定できます。
%
% 例題：
%   gtext({'This is the first line','This is the second line'})
%   gtext({'First line','Second line'},'FontName','Times','Fontsize',12)
% 
% 参考：TEXT, GINPUT.


%   L. Shure, 12-01-88.
%   Revised: Charles D. Packard 3-8-89
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:53:58 $
