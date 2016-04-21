% MSGBOX   メッセージボックス
% 
% msgbox(Message) は、適切なサイズのFigureに合うように Message を自動的
% に改行して、メッセージボックスを作成します。Message は、文字列ベクトル、
% 文字列行列、または、セル配列です。
%
% msgbox(Message,Title) は、メッセージボックスのタイトルを指定します。
%
% msgbox(Message,Title,Icon) は、メッセージボックスに表示するアイコンを
% 指定します。Icon は、'none'、'error'、'help'、'warn'、'custom' のいずれか
% です。デフォルトは、'none' です。
%
% msgbox(Message,Title,'custom',IconData,IconCMap) は、カスタムアイコンを
% 定義します。IconData は、アイコンを定義するイメージデータを含みます。
% IconCMap は、イメージに対して使用されるカラーマップです。
%
% msgbox(Message,...,CreateMode) は、メッセージボックスがmodalかどうかを
% 設定します。また、modalでない場合、他のメッセージボックスを同じTitleで
% 置き換えるか否かを設定します。CreateMode に対して使用可能な値は、
% 'modal', 'non-modal','replace' で、non-modal' がデフォルトです。
% 
% CreateMode は、WindowStyle と Interpreter メンバーをもつ構造体になります。
% WindowStyle は、上で設定した値のいずれかを使います。Interpreter は、
% 'text' または 'none' のいずれかを使います。Interpreter に対するデフォルト
% 値は 'none' です。
%
% h = msgbox(...) は、ボックスのハンドル番号をhに出力します。
%
% ユーザが応答するまで、msgboxブロックを実行するために、入力引数リスト
% の中に、文字列 'modal' を含ませ、UIWAIT と共に msgbox へのコールを停止
% します。 
%
% ユーザが応答するまでブロックを実行する例を示します。
%    uiwait(msgbox('String','Title','modal'));
%
% カスタムアイコンを使った例を示します。
% 
%    Data=1:64;Data=(Data'*Data)/64;
%    h=msgbox('String','Title','custom',Data,hot(64))
%
% 既存の msgbox ウィンドウを再利用する例を示します。
% 
%    CreateStruct.WindowStyle='replace';
%    CreateStruct.Interpreter='tex';
%    h=msgbox('X^2 + Y^2','Title','custom',Data,hot(64),CreateStruct);
%  
% 参考： DIALOG, ERRORDLG, HELPDLG, TEXTWRAP, WARNDLG, UIWAIT.


%  Copyright 1984-2002 The MathWorks, Inc.
%  $Revision: 1.9.4.1 $
