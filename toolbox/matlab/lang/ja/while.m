% WHILE   不定回数の繰り返しステートメント
% 
% WHILEステートメントの一般的な書式は、つぎのようになります。
% 
%    WHILE expression
%      statements
%    END
% 
% statementsは、expressionの実部がすべて0でない要素である間、実行され
% ます。expressionは、ropが =  = 、<、>、< = 、> = 、~ = のとき、通常
% expr rop exprの結果です。
%
% BREAKステートメントは、ループを終了するために使用されます。
%
% たとえば(Aが既に定義されていると仮定します)
%  
%           E = 0*A; F = E + eye(size(E)); N = 1;
%           while norm(E+F-E,1) > 0,
%              E = E + F;
%              F = A*F/N;
%              N = N + 1;
%           end
%
% 参考：FOR, IF, SWITCH, BREAK, CONTINUE, END.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:36 $
%   Built-in function.