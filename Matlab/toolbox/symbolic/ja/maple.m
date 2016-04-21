% MAPLE   Maple のカーネルへのアクセス
% MAPLE(STATEMENT) は、Maple のカーネルへ STATEMENT を送ります。
% STATEMENT は、文法的に有効な Maple のコマンドを表わす文字列です。必要
% ならば、Maple のシンタックスに対するセミコロンが STATEMENT に付加され
% ます。結果は、Maple のシンタックスの文字列です。
%
% MAPLE('function', ARG1, ARG2, ..,) は、シングルコートで囲まれた Maple 
% の関数名と対応する引数を受け入れます。Maple のステートメントは、func-
% tion(arg1, arg2, arg3, ...) のようになります。つまり、引数の間にカンマ
% が付加されます。すべての入力引数は、Maple の文法的に有効な文字列でなけ
% ればなりません。結果は、Maple のシンタックスの文字列として出力されます。
% 結果を Maple の文字列からシンボリックオブジェクトに変換するには、SYM 
% を使います。
%
% [RESULT, STATUS] = MAPLE(...) は、ワーニング/エラーステータスを出力し
% ます。ステートメントの実行が成功すると、RESULT には結果が出力され、STA
% TUS には 0 が出力されます。実行が失敗すると、RESULT には対応するワーニ
% ング/エラーメッセージが出力され、STATUS には正の整数が出力されます。
%
% ステートメント
%    maple traceon、または、
%    maple trace on
%   
% は、その後に続く Maple コマンドを起動し、結果を表示します。
% 
% ステートメント
% 
%   maple traceoff、または、 
%   maple trace off
% 
% は、上記の機能を終了します。
% 
% ステートメント、
% 
%   maple clear、または、
%   maple restart
%   
% は、Maple ワークスペースを消去し、Maple カーネルを初期化します。
%
% MAPLE は、Student Version においては利用できません。
%
% 参考   SYM, SYM/MAPLE



%   Copyright 1993-2002 The MathWorks, Inc. 
