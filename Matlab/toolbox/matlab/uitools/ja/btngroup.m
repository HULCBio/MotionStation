% BTNGROUP   ツールバーボタングループの作成
% 
% H = BTNGROUP('Property1', value, 'Property2', value, ...) は、ツールバー
% ボタングループを作成し、axesのハンドル番号をHに出力します。
% H = BTNGROUP(FIGHANDLE、'Property1'、value、...) は、ボタングループを、
% FIGHANDLE で識別されるfigureに設定します。
% [H,HB] = BTNGROUP(...) は、axesオブジェクトの代わりに、スタイルプッシュ
% ボタンとトグルボタンのuicontrol からボタン群を作成します。演算のこの 
% モードで、axes とその子オブジェクトは作成できますが、非可視状態になり
% ます。すなわち、uicontrolの cdata が、getframe を通してイメージキャプチャ
% から得られるので、ボタン群の位置のプロパティは空で設定されていることに
% 注意してください。HB は、ボタン群に関する uicontrol ハンドル番号の
% ベクトルです。このモードで、ボタンに対するイメージキャプチャを回避する
% ために 'Cdata' プロパティを渡します(そのため、関数をホールドしないで
% コールする前にaxesの位置を必要とします)。
% 
% 必要なプロパティ: 
%     'GroupID'  - ボタングループの識別子の文字列。
%     'ButtonID' - 各々のボタンに対する識別子の文字列を含む行列。文字列
%                  ButtonID は、内部にスペースを含んではいけません。
%
% オプションのプロパティ:
%     'IconFunctions' - アイコンの描画の表現を含む文字列または文字列から
%                       なる行列。文字列からなる行列の場合、ButtonID と同じ
%                       行数でなければなりません。アイコンの描画の表現は、
%                       カレントのaxes内で作成されるオブジェクトHGのハンドル
%                       番号を出力します。オブジェクトHGは、範囲 [0 1 0 1]に
%                       描画されます。
% 
%     'Cdata'         - ボタンに対する3次元 cdata 行列のセル配列。この
%                       プロパティは、演算の'uicontrol'モード、すなわち、
%                       2番目の出力引数 HB が存在する場合のオプションのみ
%                       であることに注意してください。このパラメータが
%                       用意されている場合は、'IconFunctions' プロパティは
%                       無視されることに注意してください。
% 
%    'PressType'      - 'flash'(これが押されると、ボタンはポップダウン
%                       してから元に戻ります)、または 'toggle'(ボタンの
%                       状態を変更し、"sticks" します)のいずれかです。
%                       'PressType'は、文字列または文字列行列です。文字列
%                       行列の場合は、ButtonID と同じ行数でなければなり
%                       ません。デフォルトは、'toggle'です。
%                       
%    'Exclusive'      - 'yes'(ボタングループはラジオボタンのような挙動を
%                       します)または 'no' です。'yes' の場合は、'PressType'
%                       プロパティは無視されます。デフォルトは、'no'です。
% 
%    'Callbacks'      - ボタンが押された状態を解除されるとき評価される表現
%                       を含む文字列。値は、文字列、または、文字列行列です。
%                     
%   'ButtonDownFcn'   - ボタンが押されたとき評価される文字列値は、文字列
%                       でも、文字列からなる行列でも構いません。
% 
%   'GroupSize'       - ボタンのレイアウトを指定する2要素のベクトル
%                       ([nrows ncols])。
%                       デフォルトは、[numButtons 1] です。
% 
%   'InitialState'    - 0(ボタンが最初に押されていない)と1(ボタンが最初に
%                       押されている)を要素とするベクトル。デフォルトは、
%                       zeros(numButtons, 1) です。
% 
%   'Units'           - ボタングループのaxesの単位。デフォルトは、figure
%                       のデフォルトのaxesの単位です。
% 
%   'Position'        - ボタングループのaxesの位置。デフォルトは、figureの
%                       デフォルトのaxesの位置です。
% 
%   'BevelWidth'**    - ボタンの幅に対する3次元の斜めの幅の割合。デフォルト
%                       は、0.05です。
% 
%   'ButtonColor' **  - 初期ボタンのバックグランドカラーfigureの 
%                       DefaultUIControlBackgroundColor がデフォルトです。
% 
%   'BevelLight'**      - 右斜め上隅の初期のカラー。
% 
%   'BevelDark'**       - 右斜め下隅の初期のカラー。
%
% ** 注意：つぎのプロパティは、'uicontrol' モードから削除されました。
%          BevelWidth, ButtonColor, BevelLight, BevelDark
% 
% 例題:
%         icons = ['text(.5,.5,''B1'',''Horiz'',''center'')'
%                  'text(.5,.5,''B2'',''Horiz'',''center'')'];
%         callbacks = ['disp(''B1'')'
%                      'disp(''B2'')'];
%         btngroup('GroupID', 'TestGroup', 'ButtonID', ...
%             ['B1';'B2'], 'Callbacks', callbacks, ...
%             'Position', [.475 .45 .05 .1], 'IconFunctions', icons);
%
%  参考： BTNSTATE, BTNPRESS, BTNDOWN, BTNUP, BTNRESIZE.


%  Steven L. Eddins, 29 June 1994
%  Tom Krauss, 27 June 1999 - Added uicontrol functionality
%  Copyright 1984-2002 The MathWorks, Inc. 
%  $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:07:42 $
