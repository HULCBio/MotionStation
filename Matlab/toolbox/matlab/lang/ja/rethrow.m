% RETHROW  エラーの再発行
%
% RETHROW(ERR) は、変数 ERR に格納されたエラーを再発行します。現在実行
% している M-ファイルを終了し、制御がキーボード(または、任意に囲まれて
% いる CATCH ブロック)に返されます。ERR は、少なくとも以下の2つのフィー
% ルドを含む構造体でなければなりません。
%
%       message    : エラーメッセージのテキスト
%       identifier : エラーメッセージのメッセージ識別子
%
% (エラーメッセージ識別子についての多くの情報については、 ERROR のヘル
% プを参照してください)
% 最後のエラー発行に対する有効な ERR 構造体を取得する便利な方法は、
% LASTERROR 関数によるものです。
%
% RETHROW は、通常、catch 関連の操作の実行後に CATCH ブロックからの
% エラーを再発行するために、TRY-CATCH ステートメントと組み合わせて利用
% します。例えば以下のように実行します:
%
%       try
%           do_something
%       catch
%           do_cleanup
%           rethrow(lasterror)
%       end
%
% 参考:  ERROR, LASTERROR, LASTERR, TRY, CATCH, DBSTOP.

    
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:59:27 $
%   Built-in function.
