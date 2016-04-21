% UISETFONT   フォント選択ダイアログボックス
% 
% S = UISETFONT(FIN、'dialogTitle') は、ユーザが入力するためのダイアログ
% ボックスを表示し、入力したグラフィックスオブジェクトに選択したフォント
% を適用します。
%
% パラメータは、オプションで、任意の順序で指定できます。
%
% パラメータFINが使用されると、textまたはuicontrol,axesオブジェクトの
% いずれかのハンドル番号を指定するか、または、フォント構造を設定しなければ
% なりません。
%
% FIN がオブジェクトのハンドルの場合、このオブジェクトに代入されるフォント
% プロパティは、フォントダイアログボックスを初期化するために使われます。
% 
% FIN が構造体の場合、そのメンバーは、FontName,FontUnits,FontSize,
% FontWeight,FontAngle のサブセットです。そして、フォントプロパティをもつ
% オブジェクトに適切な値を設定しなければなりません。
%
% パラメータ 'dialogTitle' が使用される場合、これはダイアログボックスの
% タイトルを含む文字列です。
%
% 出力 S は、構造体です。構造体 Sは、メンバとしてフォントプロパティ名を
% 出力します。
% メンバーは、FontName,FontUnits,FontSize,FontWeight,FontAngle です。
%
% ユーザがダイアログボックスからCancelボタンを押したり、エラーが発生する
% と、出力値は、0に設定されます。
%
% 例題:
%         Text1 = uicontrol('style','text','string','XxYyZz');
%         Text2 = uicontrol('style','text','string','AxBbCc',...
%                 'position', [200 20 60 20]);
%         s = uisetfont(Text1, 'Update Font');
%         if isstruct(s)           % キャンセルに対するチェック
%            set(Text2, s);
%         end
%
% 参考：INSPECT, LISTFONTS, PROPEDIT, UISETFONT


%   Copyright 1984-2002 The MathWorks, Inc.
