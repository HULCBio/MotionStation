% つぎの変数は、すべて同じ行の大きさをもち、任意のmuのGUIツールで使用可
% 能です。ここで、これらはカレントのfigureからアクセスされます。
% EDITHANDLES - 評価されるエディタブルテキストのハンドル番号
% EDITRESULTS - 評価の結果が出力されるGUIツールの変数からなる文字列
% RESTOOLHAN  - 結果が出力されるツールのハンドル番号を表わす整数
%   sguivar(EDITRESULTS,eval(EDITHANDLES),RESULTTOOLHAN)
% ERRORCB     - eval内でエラーが発生した場合に実行するコマンドの文字列
% SUCCESSCB   - evalが成功したときに実行するコマンドの文字列
% MINFOTAB    - evalから出力される変数に対するMINFOデータを含むn行4列の
%               行列
%
% これはスクリプトファイルなので、すべてのevals()はワークスペースで実行
% されます。

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:30:35 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
