% PLOTEDIT   プロットの編集と注釈付けのためのツール
% 
% PLOTEDIT ON は、カレントのfigureに対して、プロットエディットモードを
% 開始します。
% PLOTEDIT OFF は、カレントのfigureに対して、プロットエディットモードを
% 終了します。
% PLOTEDIT は、引数を設定しないと、カレントのfigureに対してプロット
% エディットモードを切り替えます。
% 
% PLOTEDIT(FIG) は、figure FIGに対してプロットエディットモードを切り
% 替えます。 
% PLOTEDIT(FIG,STATE) は、figure FIGに対して PLOTEDIT STATE を指定し
% ます。
% PLOTEDIT('STATE') は、カレントのfigureに対して、PLOTEDIT STATE を
% 指定します。
%
% STATEは、つぎの文字列の中から指定します。
%    ON            - プロットエディットモードを開始します。
%    OFF           - プロットエディットモードを終了します。
%    SHOWTOOLSMENU - ツールメニューを表示します(デフォルト)。
%    HIDETOOLSMENU - メニューバーからツールメニューを消去します。   
%
% PLOTEDIT が ON のとき、オブジェクトを修正したり追加するには、ツール
% メニューを使ってください。また、テキスト、ライン、矢印のような注釈を
% 追加するには、注釈のツールバーのボタンを選択してください。それらの
% 注釈を移動またはリサイズするには、オブジェクトをクリックしてから
% ドラッグしてください。
% 
% オブジェクトプロパティを変更するには、オブジェクト上で右マウスボタン
% クリックまたはダブルクリックしてください。
% 
% 複数のオブジェクトを選択するには、Shiftを押してクリックを行ってください。
%
% 参考: PROPEDIT  

%   toolbox-plotedit 互換性に対する内部インタフェース
%
%   plotedit(FIG,'hidetoolsmenu')
%      は、標準の figure 'Tools' メニューを非表示にします。
%   plotedit(FIG,'showtoolsmenu')
%      は、標準の figure 'Tools' メニューを表示します。
%   h = plotedit(FIG,'gethandles')
%      は、非表示の plot editor オブジェクトのリストを返します。これは、
%      GUIDE のオブジェクトブラウザから除かれる必要があります。
%   h = plotedit(FIG,'gettoolbuttons')
%      は、ツールバーに、plot editing と注釈のボタンのリストを
%      返します。 UISUSPEND と UIRESTORE により使用されます。
%   h = plotedit(FIG,'locktoolbarvisibility')
%      は、ツールバーのカレントの状態をフリーズします。
%   plotedit(FIG,'setsystemeditmenus')
%      は、system Edit メニューを再保存します。
%   plotedit(FIG,'setploteditmenus')
%      は、plotedit Edit メニューを再保存します。
%
%   これらは、UISUSPEND/UIRESTORE により使用されます。
%   a = plotedit(FIG,'getenabletools')
%      は、plot editing ツールの利用可能な状態を返します。
%   plotedit(FIG,'setenabletools','off')
%      Tools メニュー下の plot editing ツール、ツールメニューの状態を
%      更新するコールバック、および、Toolbar の plot editing ツールを
%      利用できない状態にします。
%   plotedit(FIG,'setenabletools','on')
%      は、Tools メニューとその下のアイテムを利用可能にし、
%      Toolbar の plot editing ボタンを利用可能にします。
%
%   figure ツールバーを非表示にするためには、figure 'ToolBar'
%   プロパティ (hidden) を 'none' に設定します。
%      set(fig,'ToolBar','none');
%   
%   plotedit({'subfcn',...}) は、サブ関数を実行し、入力の続きとして
%   渡します。

%   Copyright 1984-2002 The MathWorks, Inc.