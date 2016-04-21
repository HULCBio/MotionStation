% DYNAMICDLGS   内部的にMathWorksが使用するためのダイナミックダイアログ
%               の作成
%
% DYNAMICDLG(m-struct | file) は、ダイアログのレイアウトを定義するために
% 渡された構造体/MAT-ファイル名を使用します。この機能はJava Swingの
% サポートを必要とします。
% ダイアログ構造体の構造体の内容は以下のとおりです。
%
%       dlgstruct -
%          - DialogTitle
%          - Tab_1
%               - Name
%               - Group_1
%                    - Name
%                    - NameVisible
%                    - BoxVisible
%                    - WidthFactor (選択自由、デフォルト = 100)
%                    - Widget_1
%                         - Name (プッシュボタン、テキスト、ラベル、
%                                 ラジオボタンで必要になります)
%                         - Type
%                         - ObjectProperty | ObjectMethod | MatlabMethod 
%                           (これらの1つを選択します)
%                         - MethodArgs (選択自由、ObjectMethod と
%                                       MatlabMethod と共に使われます)
%                         - DialogCallback (選択自由、ダイアログを更新
%                                           したい場合に使用します)
%                                           dialog to update itself)
%                         - ToolTip  (選択自由、デフォルト = '')
%                         - Enabled
%                         - Visible
%                         - Editable (選択自由、コンボボックスに対して
%                                     のみ使われます。デフォルト = false)
%                         - Entries (リストボックス、コンボボックス、
%                                    ラジオボタンで必要になります)
%                         - SelectedItem (選択自由、リストボックス、
%                                         コンボボックス、ラジオボタン、
%                                         チェックボックスで使われます)
%                         - WidthFactor (選択自由、デフォルト = 100) 
%                       :
%                    - Widget_N
%                  :
%               - Group_N
%              :
%          - Tab_N
%  
% 以下の部品が現時点でサポートされています。
%     pushbutton     radiobutton       list        edit          combobox 
%     editarea       text              label       checkbox      hyperlink
%
% Group_N および Widget_N 内の 'WidthFactor' フィールドは、レイアウトを
% 微調整するために使用できる任意のフィールドです。デフォルトでは、100が
% 設定されており、1行につき1つの部品が配置されます。これは10から100の間の
% 任意の値を設定することができます。各行の合計が100になるように、各部品に
% 対する幅の要素を選択する代わりに部品を並べて配置します。
% ダイアログ作成は、これらのダイアログの概要の日本語バージョンの作成と
% 保存のために必要であることに注意してください。これはJavaリソース
% バンドルを利用することで使用可能になります。
%
% 参考 : MODELEXPLORER.


%   Copyright 2002 The MathWorks, Inc.
