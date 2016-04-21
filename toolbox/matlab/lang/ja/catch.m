% CATCH   CATCHブロックの開始
% 
% TRY ステートメントの一般的な形式は、つぎのようになります。
% 
%   TRY statement、...、statement、CATCH statement、...、statement END
%
% 通常、TRYとCATCHの間にあるstatementのみが実行されます。しかし、任意の
% statementの実行中にエラーが発生した場合、エラーはLASTERRに取り込まれ、
% CATCHとENDの間のstatementが実行されます。エラーがCATCHステートメント
% 内で発生した場合は、他のTRY...CATCHブロックにキャッチされなければ、実行
% は停止します。TRYブロックの失敗によって出力したエラー文字列は、LASTERRを
% 使って取り出すことができます。
%
% 参考 TRY, LASTERR, EVAL, EVALIN, END.

%   Copyright 1984-2002 The MathWorks, Inc. 

