% TRY   TRYブロックの開始
% 
% TRYステートメントの一般的な形式は、つぎのようになります。
% 
%    TRY statement、...、statement、CATCH statement、...、statement END
%
% 通常、TRY と CATCH の間にあるstatementのみが実行されます。しかし、い
% ずれかのstatementの実行中にエラーが発生した場合は、エラーは LASTERR
% に取り込まれ、CATCH と END の間のstatementが実行されます。エラーが
% CATCH ステートメント内で発生した場合は、他の TRY...CATCH ブロックに
% よってキャッチされなければ、実行は停止します。TRYブロックの失敗によって
% 出力したエラー文字列は、LASTERR を使って取り出すことができます。
%
% 参考 CATCH, LASTERR, EVAL, EVALIN, END.

%   Copyright 1984-2002 The MathWorks, Inc. 
