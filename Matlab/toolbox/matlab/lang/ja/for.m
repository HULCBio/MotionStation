% FOR   指定回数の繰り返しステートメント
%
% FORステートメントの一般的な書式は、つぎのようになります。
% 
%    FOR variable = expr、statement、...、statement END
% 
% expressionの列は、変数を一度に1つずつ格納し、ENDに到達するまで続く
% ステートメントが実行されます。expressionは、多くの場合は、X:Y の形式
% で、この場合、各列は単純なスカラです。例を示します(既に、Nに値が割り
% 当てられていると仮定します)。
% 
%      FOR I = 1:N,
%          FOR J = 1:N,
%              A(I,J) = 1/(I+J-1);
%          END
%      END
% 
% FOR S = 1.0: -0.1: 0.0、END は、-0.1の増分で S を進めます。
% FOR E = EYE(N)、... END は、N個の単位ベクトルを E に設定します。
%
% FORステートメント内にコロン表現が表わされる場合は、インデックスをもつ
% ベクトルは作成されないので、長いループはメモリに関してより効率的です。
% 
% BREAKステートメントは、ループを終了するために使用されます。
% 
% 参考：IF, WHILE, SWITCH, BREAK, CONTINUE, END.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:59:00 $
%   Built-in function.


