%DBSTEP ブレークポイントから複数行を実行
% DBSTEP は、実行可能なMATLABコードの複数行を実行し、終了するとデバッグモード
% に戻ります。このコマンドには4種類の形式があります。
%
% DBSTEP 
% DBSTEP nlines 
% DBSTEP IN 
% DBSTEP OUT
% 
% nlinesは、実行するライン数です。最初の形式では、つぎのラインを実行します。
% 2番目の形式は、つぎのnlines個の実行可能なラインを実行します。
% つぎの実行可能なラインが、他のM-ファイル関数を読み込むとき、3番目の形式は
% 読み込まれるM-ファイル関数内の最初の実行可能なラインに移動します。
% 4番目の形式は、関数の残りの部分を実行し、終了後すぐに停止します。
% すべての形式について、MATLAB は、出会ったブレークポイントでも実行を
% 停止します。
% 
% 参考 DBCONT, DBSTOP, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN,
%      DBSTATUS, DBQUIT.

% Copyright 1984-2002 The MathWorks, Inc.
