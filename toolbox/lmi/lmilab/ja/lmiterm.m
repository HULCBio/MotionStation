% lmiterm(termID,A,B,flag)
%
% カレントに記述されている連立LMIの中のLMIに項を追加します。項は、外側因
% 子、定数行列、Xが行列変数のときは変数項A*X*B、または、A*X'*Bです。
%
% 重要: 
% 非対角ブロック(i,j)と(j,i)は、お互いに転置されるので、これらの2つのブ
% ロックのうち1つの項の内容のみを設定してください。
%
% 入力:
%  TERMID    項の位置と性質を設定する4要素ベクトル。
%            LMI
%		TERMID(1) = +n  ->  n番目のLMIの左辺の項
%		TERMID(1) = -n  ->  n番目のLMIの右辺の項
%            ブロック
%		外側因子に対しては、TERMID(2:3) = [0 0]です。そうでなけ
%               れば、項がLMIの(i,j)ブロックに属する場合は、TERMID(2:3) 
%               = [i j]と設定します。
%            項のタイプ
%		TERMID(4) =  0  ->  定数項
%		TERMID(4) =  X  ->  変数項A*X*B
%		TERMID(4) = -X  ->  変数項A*X'*B
%               ここで、Xは、LMIVARで出力する変数の識別子です。
%  A         外側因子の値、定数項、変数項A*X*B、または、A*X'*Bの左側係数
%  B         変数項A*X*B、または、A*X'*Bの右側係数
%  FLAG      対角ブロックにおいて表現A*X*B+B'*X'*A'を設定するための簡単
%            な方法です。FLAG='s'と設定すると、1つのLMITERMコマンドで、
%            このような表現が設定できます。
%
% 参考：    SETLMIS, LMIVAR, GETLMIS, LMIEDIT, NEWLMI.



% Copyright 1995-2002 The MathWorks, Inc. 
