% OTHERWISE   SWITCHステートメントCASE文のデフォルト
% 
% OTHERWISE は、SWITCHステートメントシンタックスの一部で、一般的な書式
% は、つぎのようになります。
% 
%       SWITCH switch_expr
%         CASE case_expr, 
%           statement, ..., statement
%         CASE {case_expr1, case_expr2, case_expr3,...}
%           statement, ..., statement
%        ...
%         OTHERWISE, 
%           statement, ..., statement
%       END
%
% OTHERWISE 部分は、先行するcase文の式がswitchの式と1つと一致しない
% 場合にのみ実行されます。
%
% 詳細は、SWITCH を参照してください。


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:24 $
%   Built-in function.
