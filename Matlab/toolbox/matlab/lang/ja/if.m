% IF   条件実行ステートメント
% 
% IFステートメントの一般的な書式は、つぎのようになります。
%
%    IF expression
%      statements
%    ELSEIF expression
%      statements
%    ELSE
%      statements
%    END
%
% IF に続くexpressionの実部が非ゼロ要素である場合は、statementが実行
% されます。ELSE と ELSEIF の部分は、オプションです。ネスティングされた
% IF と同様に、0個以上のELSEIF部分を使うことができます。expressionは、
% ropが == 、<、>、< = 、> = 、~ = のときには、通常expr rop exprの書式です。 
%
% 例題
%      if I == J
%        A(I,J) = 2;
%      elseif abs(I-J) == 1
%        A(I,J) = -1;
%      else
%        A(I,J) = 0;
%      end
%
% 参考：RELOP, ELSE, ELSEIF, END, FOR, WHILE, SWITCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:04 $
%   Built-in function.
