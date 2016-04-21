% CSHELP   GUI様式の内容に依存したヘルプをインストール
%
% CSHELP(FIGHANDLE) は、ハンドル FIGHANDLE をもつfigureに対して、内容
% に依存した(CS)ヘルプをインストールします。CS ヘルプをアクティブにする
% には、つぎのように入力してください。
% 
%      set(handle(FIGHANDLE),'cshelpmode','on')
% 
% これをオフにするには、つぎのように入力してください。
% 
%      set(handle(FIGHANDLE),'cshelpmode','off')
% 
% CS ヘルプがオンになると、figure内の任意のオブジェクトをクリックする
% ことは、figure内の HelpFcn コールバックを実行することになります。
% このコールバック関数は、希望する内容依存のヘルプ書式にすることができます。
%
% CSHELP(FIGHANDLE,PARENTFIG) は、FIGHANDLE と親figure PARENTFIG に対する
% CS ヘルプで、あるfigure内の CS ヘルプを使用可能にすることは、他のものの
% 内部に位置する同じものを自動的に使用可能にします。デフォルトでは、
% FIGHANDLE は、PARENTFIG から HELPFCN と HELPTOPICAMP 値を継承します。
% これは、GUI様式の CS ヘルプシステムを作成する場合に有効です。
%
% 参考：HELPVIEW.


%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
