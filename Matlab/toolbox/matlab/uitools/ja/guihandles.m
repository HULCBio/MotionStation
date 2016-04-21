% GUIHANDLES   ハンドルの構造体を出力
% 
% HANDLES = GUIHANDLES(H) は、fieldnames としてそのタグを使って、figure
% 内のオブジェクトのハンドルを含む構造体を戻します。オブジェクトは、その
% タグが空の場合、または、正しい変数名でない場合は、削除されます。
% オブジェクトの中に同じ同じタグをもつものがある場合は、構造体のフィールド
% は、ハンドルのベクトルを含んでいます。隠れたハンドルをもつオブジェクトは、
% 構造体の中に含まれています。
%
% H は、figureを識別するハンドルで、これは、figure自身またはfigure内に
% 含まれる任意のオブジェクトになります。
%
% HANDLES = GUIHANDLES は、カレントfigureに対するハンドルの構造体を
% 出力します。
%
% 例題：
%
% ハンドル F をもつfigureを作成するアプリケーションを考えます。この中には、
% スライダや編集可能なテキストのuicontrol のタグが、それぞれ、'valueSlider' 
% と 'valueEdit' で含まれています。アプリケーションの M-ファイルからの以下
% の部分は、GUIHANDLES により出力されるハンドルを含む構造体にアクセス
% するための GUIDATA の利用を示します。
%
%   ... GUI セットアップコードの一部分...
%
%   f = figure;
%   uicontrol('Style','slider','Tag','valueSlider', ...);
%   uicontrol('Style','edit','Tag','valueEdit',...);
%
%   ... スライダのコールバックの一部分...
%
%   handles = guihandles(gcbo); % ハンドルの構造体を作成
%   set(handles.valueEdit, 'string',...
%       num2str(get(handles.valueSlider, 'value')));
%
%   ... エディットコールバックの一部分...
%
%   handles = guihandles(gcbo);
%   val = str2double(get(handles.valueEdit,'String'));
%   if isnumeric(val) & length(val)==1 & ...
%      val >= get(handles.valueSlider, 'Min') & ...
%      val <= get(handles.valueSlider, 'Max')
%     % エディット値が OK の場合はスライダ値を更新
%     set(handles.valueSlider, 'Value', val);
%   else
%     % エディットから不正な文字列を削除し、スライダのカレント値で置換
%     set(handles.valueEdit, 'String',...
%       num2str(get(handles.valueSlider, 'Value')));
%   end
%
% この例題では、コールバックが実行する度に、ハンドルの構造体が作成され
% ます。構造体が一度だけ作成され、その後の使用に対してはキャッシュされる
% 例題については、GUIDATA ヘルプを参照してください。
%
% 参考： GUIDATA, GUIDE, OPENFIG.


%   Damian T. Packer 6-8-2000
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 02:08:11 $
