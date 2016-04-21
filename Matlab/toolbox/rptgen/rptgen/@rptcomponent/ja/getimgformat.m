% GETIMGFORMAT   拡張子とデバイスの情報を出力
% a = GETIMGFORMAT(rptcomponent,ID)は、IDによって指定されたイメージの書
% 式を記述する構造体を出力します。
%   
% 有効な全ての書式を含む構造体に対しては、ID='ALL'を利用します。
% Figures, Simulink, Stateflowに対して有効な全ての書式を含む構造体に対し
% ては、それぞれID='ALLHG','ALLSL','ALLSF'を利用します。
% Figures, Simulink, Stateflowに対するデフォルトのイメージの書式を含む構
% 造体に対しては、それぞれ、ID='AUTOHG','AUTOSL','AUTOSF'を利用します。
% これらのAUTOXX イメージは、RPTPARENT/PREFERENCESで設定されます。
%
% 各構造体のフィールドを以下に示します:
% 
%     .ID      - 書式のユニークな識別子
%     .name    - 書式の説明
%     .ext     - 書式と共に用いられるファイルの拡張子
%     .driver  - プリントドライバ(-dps, -dtiff等)
%     .options - プリントオプションのセル配列
%     .isSL    - Simulinkで用いられる場合は1、そうでない場合は0。
%     .isSF    - Stateflowで用いられる場合は1、そうでない場合は0。
%     .isHG    - Handle Graphicsで用いられる場合は1、そうでない場合は0。
%
% 参考   RPTPARENT/PREFERENCES





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:20:51 $
%   Copyright 1997-2002 The MathWorks, Inc.
