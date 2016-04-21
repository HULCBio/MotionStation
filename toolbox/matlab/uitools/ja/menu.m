% MENU   ユーザ入力に対して選択メニューを作成
% 
% CHOICE = MENU(HEADER, ITEM1, ITEM2, ... ) は、文字列 HEADER と、それ
% に続いてメニューアイテム文字列 ITEM1、ITEM2、... ITEMn を表示します。
% 選択したメニューアイテム数を、スカラ値 CHOICE として出力します。メニュー
% アイテム数に制限はありません。
%
% CHOICE = MENU(HEADER, ITEMLIST) は、ITEMLIST が文字列のセル配列のとき、
% 有効なシンタックスです。
%
% ほとんどのグラフィックス端末で、MENU は、あるfigure内でボタンを押す
% ようにメニューアイテムを表示します。他の場合、コマンドウィンドウ内の
% 番号付けられたリストとして与えられます(下記の例題を参照)。
%
% コマンドウィンドウの例題:
% 
%    >> K = MENU('Choose a color','Red','Blue','Green')
% 
% は、スクリーン上につぎのものを表示します。
%
%   ----- Choose a color -----
%
%      1) Red
%      2) Blue
%      3) Green
%
%      Select a menu number:
%
% プロンプトに対応してユーザが入力した数値は、Kとして出力されます(たとえば、
% K = 2は、ユーザがBlueを選択したことを意味します)。
% 
% 参考：UICONTROL, UIMENU, GUIDE.


%   J.N. Little 4-21-87, revised 4-13-92 by LS, 2-18-97 by KGK.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:08:29 $
