%DBSTOP ブレークポイントの設定
% コマンド DBSTOP は、M-ファイル関数の実行を一時的に停止するときに使い、
% ローカルのワークスペースの内容を調べることができます。このコマンドには、
% つぎのいくつかのタイプが存在します。 
%
%   (1)  DBSTOP IN MFILE AT LINENO
%   (2)  DBSTOP IN MFILE AT SUBFUN
%   (3)  DBSTOP IN MFILE
%   (4)  DBSTOP IN MFILE AT LINENO IF EXPRESSION
%   (5)  DBSTOP IN MFILE AT SUBFUN IF EXPRESSION
%   (6)  DBSTOP IN MFILE IF EXPRESSION
%   (7)  DBSTOP IF ERROR 
%   (8)  DBSTOP IF CAUGHT ERROR 
%   (9)  DBSTOP IF WARNING 
%   (10) DBSTOP IF NANINF  あるいは  DBSTOP IF INFNAN
%   (11) DBSTOP IF ERROR IDENTIFIER
%   (12) DBSTOP IF CAUGHT ERROR IDENTIFIER
%   (13) DBSTOP IF WARNING IDENTIFIER
%
% MFILE は、M-ファイルの名前、または、MATLABPATH相対部分パス名である必要
% があります (参照 PARTIALPATH)。LINENO は、MFILE 内のライン数であり、
% SUBFUN　は、MFILE 内のサブ関数名です。EXPRESSION は、実行可能な条件式を
% 含む文字列です。IDENTIFIER は、MATLAB MessageIdentifier です (メッセージ
% 識別子の記述に対するERRORのヘルプ参照)。キーワード AT, IN はオプションです。
% 
%   10個のタイプは、つぎのものです。
%
%   (1)  MFILE 内の指定したライン番号で停止します。
%   (2)  MFILE の指定したサブ関数で停止します。
%   (3)  MFILE の最初の実行可能なラインで停止します。
%   (4-6) EXPRESSION をtrue に評価する場合をのみ停止することを除き、(1)-(3)と
%        同様です。EXPRESSION は、ブレークポイントに会うと、MFILE のワーク
%        スペースで、( EVAL による場合のように) に評価され、スカラの論理値 
%        (true または false) に評価される必要があります。
%   (7)  TRY...CATCH ブロック内で検出されない実行時エラーを起こす M-ファイル
%        関数内で停止を引き起こします。catch されなかった実行時エラーの後、 
%        M-ファイルの実行を再開することはできません。
%   (8)  TRY...CATCH ブロック内で検出された実行時エラーの原因となる M-ファイル
%        関数で停止します。実行時エラーをcatch する後、M-ファイルの実行を再開
%        できます。
%   (9)  実行時ワーニングの原因になる M-ファイル関数内で停止します。
%   (10) 無限大(Inf)、または、NaN が検知された位置に存在する 
%        M-ファイルの中で停止します。
%   (11-13) メッセージ識別子が IDENTIFIER であるエラーまたはワーニング
%         において、MATLAB が停止することを除き、(7)-(9)と同様です。   
%         ( IDENTIFIER が特定の文字列 'all' の場合、これらは、(7)-(9)
%           と同じ動作をします。)
%
% MATLAB が、ブレークポイントに出会うと、デバッグモードに入ります。
% すると、プロンプトが、K>>に変わり、デバッグメニューの 
% "Open M-Files when Debugging" の設定に依り、デバッガウィンドウがアクティブ
% になります。任意のMATLAB コマンドがプロンプトに対して入力できます。
% M-ファイルの実行を再開するには、DBCONT または、DBSTEP を使って
% ください。デバッガから抜け出すには、DBQUIT を使ってください。
%
%   参考 DBCONT, DBSTEP, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN,
%        DBSTATUS, DBQUIT, ERROR, EVAL, LOGICAL, PARTIALPATH, TRY, WARNING.

%   Steve Bangert, 6-25-91. Revised, 1-3-92.
%   Copyright 1984-2003 The MathWorks, Inc. 
