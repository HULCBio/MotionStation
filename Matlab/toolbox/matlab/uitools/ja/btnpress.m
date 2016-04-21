% BTNPRESS   ツールバーボタングループのボタンプレスマネージャ
%
% ツールバーボタングループを構成するすべてのオブジェクトは、BTNPRESS を
% 呼び出すする ButtonDownFcn をもちます。BTNPRESS は、ボタンの 'PressType' 
% プロパティとボタングループの 'Exclusive' プロパティに基づいて、正しい
% 動作を行います。BTNPRESS は、BTNDOWN と BTNUPを 呼び出して、実際の
% ボタンの外観を変更します。
%
% BTNPRESS は、コマンドラインから使用して、つぎの呼び出しを使ってボタン
% プレスをシミュレーションします。
% BTNPRESS(FIGHANDLE, GROUPID, BUTTONID)
% BTNPRESS(FIGHANDLE, GROUPID, BUTTONNUM)
%
% 参考： BTNGROUP, BTNSTATE, BTNUP, BTNDOWN, BTNRESIZE.


%  Steven L. Eddins, 29 June 1994
%  Copyright 1984-2002 The MathWorks, Inc. 
%  $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:07:44 $
