% PDEDLG は、PDE Toolbox 用の PDE 仕様のダイアログボックスを管理します。
% 'Specify PDE'-ボタンをクリックするか、または、PDE メニューから Param-
% eters... を選択するかで、PDETOOL からコールされます。
%
%   PDEDLG(ACTION,FLAG,TYPE,TYPERANGE,EQUSTR,PARSTR,VALSTR,DESCRSTR)
%
% 引数 ACTION と FLAGは、フィギュアイベントをコントロールするために使わ
% れます。引数 TYPE は、PDE のタイプを設定するものです。TYPERANGE は、カ
% レントの PDE Toolbox アプリケーション用の PDE タイプ用のベクトルです。
% 引数 EQUSTR, PARSTR, VALSTR, DESCRSTR は、方程式、係数名、カレント値、
% 係数の記述を、それぞれ含む文字行列です。
%
% 参考   PDETOOL

%       Copyright 1994-2001 The MathWorks, Inc.
