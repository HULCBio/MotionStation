% TABDLG   タブ付きのダイアログボックスの作成と管理
% 
% [hfig、sheetPos] = tabdlg(...
%   'create',strings,tabDims,callback,sheetDims,offsets,default_page)
%
% create       - ダイアログの作成を要求するフラグ。
% strings      -  タブのラベルを要素とするセル配列。
% tabDims      - 長さ2のセル配列。
% tabDims{1}   - 各々のタブの幅をピクセル単位で指定する 'strings' と同じ
%                長さのベクトル。
% tabDims{2}   - strings の高さを指定するスカラ(ピクセル単位)。
%
% 詳細は、このヘルプの"追加的な機能"のセクションを参照してください。
% 
% callback     - 新たなタブが選択される毎に呼び出されるコールバック関数名。
%                コールバック関数は、つぎの引数を使って呼び出されます。
%            1) 'tabcallbk'     - テキストフラグ
%            2) pressedTab      - 選択したタブの文字列
%            3) pressedTabNum   - 選択したタブの個数
%            4) previousTab     - 以前に選択したタブの文字列
%            5) previouTabNum   - 以前に選択したタブの個数
%            6) hfig            - figureのハンドル番号
%
%                コールバック関数は、実際のタブの管理だけではなく、タブ
%                付きのダイアログボックスも管理しなければなりません(たと
%                えば、コントロールの可視化機能の切り替え)。
%
% sheetDims    - タブシートの[width、height](ピクセル単位)。  
% offsets      - シートのエッジとfigureの境界の間のオフセットからなる4要
%                素のベクトル(ピクセル単位)。
%          [ figureの左端からのオフセット
%            figureの上部からのオフセット
%            figureの右端からのオフセット
%            figureの底からのオフセット ]
%
% default_page - 作成時に表示されるページ番号。
%
% オプション引数
% font         - 2要素のセル配列(8番目の引数)。
%                {'fontname'、fontsize}
%        
%                FactoryUicontrolFontNameとFactoryUiControlFontSizeは、
%                デフォルトで使用されます。
%
% hfig         - figureウィンドウのハンドル(9番目の引数)。
%                このオプションが使用される場合、引数'font'も指定され
%                なければなりません。デフォルトのフォントを希望する場合は
%                {} を使用してください。幾何的な計算に対するテキストの
%                範囲を得るために、figure を作成する必要がある場合があり
%                ます。この場合、figureを作成し、幾何学計算を行い、それ
%                から tabdlg を呼び出してください。既存のfigureが、
%                タブダイアログボックスに対して使用されます。tabdlgを呼び
%                出すまで、figure上にはコントロールを置かないでください。
%
%                注意: 
%                hfigは非整数のハンドル番号で、figueは視覚不可能であると
%                仮定されています。
%
% 出力:
% hfig         - 新たに作成されたタブダイアログボックスのハンドル番号。
% sheetPos     - シートに対する4要素の位置ベクトル。
%
% 注意: 
% これ以降の処理が行われる場合があるので、ダイアログボックスは、視覚不可
% 能です。
%
% 追加的な機能
%
%      tabDims = tabdlg('tabdims'、strings、font)
% 
% 与えられたfontとstringを使うと、上記で記述した形式のセル配列tabDimsを
% 出力します。これは効率の悪い操作で、タブダイアログボックスを作成すると
% きに、すぐに実行されません。前もってこの操作を行い、作成する呼び出しに
% widthを与えると、より良い結果を出力します。
% 
%   strings - 上記の説明を参照。
%   font    - 上記の説明を参照。
%
% 例題: 
% 
%     tabDims = tabdlg('tabdims'、{'cat'、'bird'});
%
% 注意: fontは、オプションの引数です。
% 注意: heightは、stringの高さです。タブの高さではありません。


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:08:52 $
