% AXLIMDLG   Axes limitsダイアログボックス
% 
% FIG = AXLIMDLG(DlgName,OptionFlags,PromptString,AxesHandles,....
%       XYZstring,DefLim, ApplyFcn) は、DlgName という名前で、PromptString
% の行で与えられるプロンプトをもつ、Axes limitsダイアログボックスを作成
% します。
% 
% OptionFlags  - フラグからなる行ベクトル
%                1列目: 自動範囲設定チェックボックス(1 = yes、0 = no)
%                2列目: 対数スケールチェックボックス(1 = yes、0 = no)
%                デフォルトは、両方ともoffです。
% PromptString - 各行がプロンプトテキストである文字列行列
% AxesHandles  - axisのベクトル。NaNは、PromptString に従ってaxesを分割
%                します。
% XYZstring    - PromptString と同じ行数の文字列行列
% DefLim       - PromptString と同じ行数の文字列行列
% ApplyFcn     - Applyボタンコールバックに付け加えられる単一行の文字列。
%                ダイアログが壊される前に、ダイアログから文字列や範囲を
%                抽出するのに役立ちます。
%
% 例題 1
% 
%    axlimdlg
% 
% は、gca コマンドで機能する標準のaxes limitダイアログボックスを出力します。
% 
% 例題 2
% 
%    axlimdlg('MyName')
% 
% は、gca コマンドで機能する MyNam eという名前の標準のaxes limitsダイアロ
% グボックスを出力します。
% 
% 例題 3
% 
%    axlimdlg('MyName',[1 1])
% 
% は、gca コマンドで機能する MyName という名前のaxes limitsダイアログボック
% スを作成し、自動範囲設定と対数/線形スケールについてのチェックボックス
% をもちます。
% 
% 例題 4
% 
% GainAx と PhaseAx は、Bodeプロットのaxesのハンドル番号です。
% 
%    DlgName = 'Bode axes limit dialog';
%    OptionFlags = [0 0];
%    PromptString = str2mat('Frequency range:','Gain Range:',...
%        'Phase range:');
%    AxesHandles = [GainAx PhaseAx NaN GainAx NaN PhaseAx];
%    XYZstring = ['x'; 'y'; 'y'];
%    DefLim = [get(GainAx,'XLim'); get(GainAx,'YLim'); ...
%       get(PhaseAx,'YLim')];
%    axlimdlg(DlgName,OptionFlags,PromptString,AxesHandles,...
%       XYZstring,DefLim)
%
% 注意:
% 1) ダイアログには、EditCallback または ApplyCallbackという名前を使わないで
%    下さい。
% 2) 空のaxesまたは正しくないaxesのハンドル番号を設定するときには、
%    エラーダイアログを作成してください。有能なアプリケーションプログラマは、こ
%    の場合は、ダイアログボックス内のaxesハンドルを更新するか、必要ならダイ
%     アログボックスを壊そうとします。
% 3) Figure UserData は、各々の PromptString の行 [PromptText EditField 
%    AutoCheckbox LogCheckbox] に対して、1行のハンドルを含みます。
% 4) PromptText UserData は、axesのハンドル番号を含みます。
% 5) EditField UserData は、有効な軸の範囲を含みます。
% 6) トップフレームuicontrol UserDataは、XYZstringを含みます。


%   Author(s): A. Potvin, 10-25-94, 1-1-95
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 02:07:40 $

