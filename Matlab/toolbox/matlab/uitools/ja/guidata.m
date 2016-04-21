% GUIDATA    アプリケーションデータをストアし、読み込みます。
%
% GUIDATA(H, DATA) は、figureのアプリケーションデータ内の指定したデータ
% を保存します。
%
% H は、figureを識別するハンドルで、figure自身、またはfigure内に含まれる
% 任意のオブジェクトでも構いません。
%
% DATA は、後で読み込むための保存を希望する任意のアプリケーションを表わ
% します。
%
% DATA = GUIDATA(H) は、前にストアしたデータを出力し、前にストアしたもの
% がない場合は、空行列を出力します。
%
% GUIDATA は、figureのアプリケーションデータへの便利なインタフェースをもつ
% アプリケーションを用意しています。ユーザは、figureのハンドルを探索せずに
% コールバックサブ関数からデータをアクセスできます。ユーザのソースコードに
% より、アプリケーションデータ用にハードコードされたプロパティ名を作成し
% たり、維持することも回避することができます。GUIDATA は、GUIHANDLES と
% 共に使用すると、特に有効です。GUIHANDLES は、タグによりリストされたGUI 
% の中のすべての要素のハンドルを含む構造体です。
%
% 例題：
%
% ハンドル F をもつfigureを作成するアプリケーションを考えます。この中には、
% のタグが、それぞれ、 'valueSlider' と 'valueEdit' である、スライダや
% 編集可能なテキストのuicontrolが含まれています。アプリケーションの 
% M-ファイルからの以下の部分は、GUIHANDLES により出力されるハンドルを
% 含む構造体にアクセスするための GUIDATA の利用を示します。それと共に、
% これらの中には、初期化とコールバックの間にアプリケーション固有なハン
% ドルも含んでいます。
%
%   ... GUIセットアップの一部分...
%
%   f = openfig('mygui.fig');
%   data = guihandles(f); % ハンドルを含ませて初期化
%   data.errorString = 'Total number of mistakes: ';
%   data.numberOfErrors = 0;
%   guidata(f, data);  % 構造体をストア
%
%   ... スライダのコールバックの一部分...
%
%   data = guidata(gcbo); % 構造体を取得して、ハンドルを使用
%   set(data.valueEdit, 'String',...
%       num2str(get(data.valueSlider, 'Value')));
%
%   ... エディットのコールバックの一部分...
%
%   data = guidata(gcbo); % ハンドルが必要、エラー情報が必要な場合もあり
%   val = str2double(get(data.valueEdit,'String'));
%   if isnumeric(val) & length(val)==1 & ...
%      val >= get(data.valueSlider, 'Min') & ...
%      val <= get(data.valueSlider, 'Max')
%     set(data.valueSlider, 'Value', val);
%   else
%     % エラー回数をカウントして表示
%     data.numberOfErrors = data.numberOfErrors + 1;
%     set(handles.valueEdit, 'String',...
%      [ data.errorString, num2str(data.numberOfErrors) ]);
%     guidata(gcbo, data); % 変更をストア
%   end
%
% GUIDE は、入力引数として自動的にハンドルの構造体が渡されるコールバック
% 関数を作成することに注意してください。これは、GUIDE を利用して書かれる
% コールバックで、"data = guidata(gcbo);"を呼び出すする必要がなくなります。
%
% 参考： GUIHANDLES, GUIDE, OPENFIG, GETAPPDATA, SETAPPDATA.


%   Damian T. Packer 6-8-2000
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 02:08:08 $
