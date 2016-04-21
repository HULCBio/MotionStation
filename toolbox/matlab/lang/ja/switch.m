% SWITCH   式に基づきcase文間で実行を切り替えます｡
% 
% SWITCHステートメントの一般的な書式は、つぎのようになります。
%
%     SWITCH switch_expr
%       CASE case_expr、
%         statement、...、statement
%       CASE {case_expr1、case_expr2、case_expr3,...}
%         statement、...、statement
%      ...
%       OTHERWISE、
%         statement、...、statement
%     END
%
% switch_expr が case_expr と一致する最初のCASE文が実行されます。case
% 式がセル配列のとき(上記の2番目のcaseのように)は、セル配列の要素の
% いずれかがswitch式と一致すれば、case_exprが一致します。case式のいず
% れもswitch式と一致しなければ、(存在すれば)OTHERWISE case文が実行
% されます。1つのCASE文が実行され、ENDの後のステートメントを使って再
% び実行されます。
%
% switch_expr は、スカラまたは文字列です。switch_expr =  = case_expr の
% 場合は、スカラのswitch_expr は case_expr と一致します。
% strcmp(switch_expr,case_expr) が1を出力する場合は、文字列の
% switch_expr は、case_expr と一致します。
%
% 一致した CASE とつぎのCASE, OTHERWISE,END のいずれかとの間のス
% テートメントのみが実行されます。Cと異なり、SWITCH ステートメントは、
% BREAK を必要としません。
% 
% 例題
%
% 文字列 METHOD に設定されているものをベースに種々のコード群を実行します。
% 
%
%       method = 'Bilinear';
%
%       switch lower(method)
%         case {'linear','bilinear'}
%           disp('Method is linear')
%         case 'cubic'
%           disp('Method is cubic')
%         case 'nearest'
%           disp('Method is nearest')
%         otherwise
%           disp('Unknown method.')
%       end
%
%       Method is linear
% 
% 参考：CASE, OTHERWISE, IF, WHILE, FOR, END.

%   Copyright 1984-2002 The MathWorks, Inc. 

