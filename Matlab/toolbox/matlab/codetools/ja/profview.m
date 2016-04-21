%PROFVIEW   HTML プロファイラインタフェースの表示
% PROFVIEW(FUNCTIONNAME, HILITEOPTION, PROFILEINFO)
% FUNCTIONNAME は、プロファイルへの名前またはインデックス番号のいずれかに
% なることができます。
% PROFILEINFO は、つぎにより profile stats 構造体です。
% PROFILEINFO = PROFILE('INFO').
% 渡された FUNCTIONNAME 引数がゼロの場合、profview は、プロファイルの
% をまとめたページを表示します。
% HILITEOPTION は、ファイルリスト内のコードの後ろの色を参照します。
% HILITEOPTION = {'time','numcalls','coverage','noncoverage','none'}
%
% PROFVIEW に対する出力は、プロファイラウィンドウの HTML ファイルです。
% 関数プロファイルページの下にリストされているファイルは、コードの各行
% の左の列です。
%  * 列 1 (赤) は、そのラインに費やされた時間の合計(s)です。
%  * 列 2 (青) は、そのラインへのコールの番号です。
%  * 列 3 は、ライン番号です。
%
% 参考 PROFILE.

%   Copyright 1984-2003 The MathWorks, Inc.
