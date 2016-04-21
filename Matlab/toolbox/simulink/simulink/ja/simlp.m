% SIMLP   GETXO で利用される関数; 線形計画問題を解く
%
% X = SIMLP(f,A,b)は、線形計画問題を解きます。
%
%            min f'x    制約条件:   Ax < =  b
%             x
%
% X = SIMLP(f,A,b,VLB,VUB) は、設計変数 X の下限と上限を、解が常に
% VLB < =  X < =  VUBの範囲であるように定義します。
%
% X = SIMLP(f,A,b,VLB,VUB,X0) は、初期値を X0 に設定します。
%
% X = SIMLP(f,A,b,VLB,VUB,X0,N) は、A と b によって定義された最初のN個の
% 制約が等式制約であることを示します。
%
% X = SIMLP(f,A,b,VLB,VUB,X0,N,DISPLAY) は、表示するワーニングメッセージ
% のレベルを制御します。ワーニングメッセージは、DISPLAY  =  -1 とする
% ことにより非表示にできます。
%
% [x,LAMBDA] = SIMLP(f,A,b) は、解におけるラグランジェ乗数、LAMBDA を
% 出力します。
%
% [X,LAMBDA,HOW]  =  SIMLP(f,A,b) は、繰り返しの最後の誤差の状態を表す
% 文字列も出力します。
%
% SIMLP は、解に範囲が与えられていないか、実行不可能であるときに、
% ワーニングメッセージを出力します。
%
% SIMLP は、private/QPSUB を呼び出します。
%
% 参考 : GETX0.


%   Copyright 1990-2002 The MathWorks, Inc.
