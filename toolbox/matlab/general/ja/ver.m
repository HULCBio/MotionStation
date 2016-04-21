% VER 　　MATLAB, Simulink, Toolbox のバージョン情報を表示
%
% VER は、カレントのMATLAB、Simulinkおよびツールボックスのバージョン
% 番号を表示します。
% VER(TOOLBOX_DIR) は、文字列 TOOLBOX_DIR で設定したツールボックス
% のカレントバージョン情報を表示します。
% A = VER は、一般のMATLABバージョンのヘッダを表示し、A にMATLABパス上
% にあるすべてのツールボックスのバージョン情報を格納した構造体配列を
% 出力します。
% 構造体 A の記述は以下のとおりです:
%           A.Name      : ツールボックス名
%           A.Version   : ツールボックスのバージョンナンバー
%           A.Release   : ツールボックスのリリース文字列
%           A.Date      : ツールボックスのリリース日
% たとえば、
%      ver control
% Control System Toolbox に関するバージョン情報を表示し、アルファベット
% 順にソートします。
%      A = ver('control');
% は、Control System Toolbox に関するバージョン情報を A に出力し、アル
% ファベット順にソートします。
%
% ユーザのツールボックスに関するバージョン情報を表示するために VER を
% 使う方法のヒントは、MATLABプロンプトでつぎのように入力してください。
%       more on
%       type ver.m
% そして、ver.m の表示が終了した場合、'more off' とタイプします。
%
% 参考：VERSION, HOSTID, LICENSE, INFO, WHATSNEW.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/04/28 01:53:43 $

