% CALLHELP   ヘルプファイルの指定されたセクションを呼び出して表示
%
% CALLHELP(FILE) は、FILE の全内容を MATLAB ワークスーペースに表示します。
% 
% CALLHELP(FILE, STR) は、FILE 内の [STR '_help_begin']、および、
% [STR '_help_end'] を探索して、そのセクションを MATLAB ワークスペース
% に表示します。
% 
% CALLHELP(FILE, STR, ADDITION) は、1行空けて追加情報を表示します。
% 
% ERR = CALLHELP(...) は、エラーメッセージを表示します。
% ERR = 0,コマンの実行は成功しました。
% ERR = -2,ファイルが見つからない。
%
% 参考： AMOD, ADEMOD, DMOD, DDEMOD, AMODCE, ADEMODCE, ENCODE, DECODE.


%       Wes Wang 1/16/95, 9/30/95
%       Copyright 1996-2002 The MathWorks, Inc.
%       $Revision: 1.5.4.1 $
