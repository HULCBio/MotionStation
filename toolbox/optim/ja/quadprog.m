% QUADPROG は、二次計画法
%
% X = QUADPROG(H,f,A,b) は、つぎの型で、二次計画法を解きます。
%
% A*x < =  b の制約のもとで、0.5*x'*H*x + f'*x を x について最小化します。
% 
% X = QUADPROG(H,f,A,b,Aeq,beq) は、等式制約 Aeq*x = beq のもとで、上の
% 問題を解きます。
%
% X = QUADPROG(H,f,A,b,Aeq,beq,LB,UB) は、設計変数 X の上下限の範囲を定義
% します。ここで、解は、LB <= X <= UB の範囲に入ります。範囲の制約がない
% 場合、LB と UB に空行列を設定してください。X(i) に下限がない場合、
% LB(i) = -Inf とし、X(i) に上限がない場合、UB(i) = Inf と設定します。
%
% X = QUADPROG(H,f,A,b,Aeq,beq,LB,UB,X0) は、初期値 X0 を使用します。
%
% X = QUADPROG(H,f,A,b,Aeq,beq,LB,UB,X0,OPTIONS)  は、OPTIMSET 関数に
% よって、引数が作成された OPTIONS 構造体をデフォルトオプションパラメータ
% を置き換えます。詳細は、OPTIMSET を参照してください。ここでは、Display, 
% Diagnostics, TolX, TolFun, HessMult, LargeScale,   MaxIter, 
% PrecondBandWidth, TypicalX, TolPCG, MaxPCGIter パラメータが使われます。
% パラメータ Display に対して、'final' と 'off' が使用でき、'iter'は
% 使用できません。
%
% [X,FVAL] = QUADPROG(H,f,A,b) は、X での目的関数値 FVAL = 0.5*X'*H*X + 
% f'*X を出力します。
%
% [X,FVAL,EXITFLAG] = QUADPROG(H,f,A,b) は、QUADPROG の終了状況を示す
% 文字列 EXITFLAG を出力します。
% EXITFLAG は、つぎの意味を表わします。
%    > 0 の場合、QUADPROG は、解 X に収束しています。
%    0   の場合、関数計算の繰り返し回数が、設定している最大回数に達して
%                います。
%    < 0 の場合、QUADPROG は、有限でない、非可解、または、解に収束しま
%                せんでした。
%
% [X,FVAL,EXITFLAG,OUTPUT] = QUADPROG(H,f,A,b) は、繰り返し回数 
% OUTPUT.iterations、使用したアルゴリズム OUTPUT.algorithm、(使用した
% 場合)CG 繰り返しの回数 OUTPUT.cgiterations 、(使用した場合)一次の最適値 
% OUTPUT.firstorderopt を構造体 OUTPUT に出力します。
%
% [X,FVAL,EXITFLAG,OUTPUT,LAMBDA] = QUADPROG(H,f,A,b) は、解における
% ラグランジュ(Lagrangian)乗数 LAMBDA を出力します。: LAMBDA.ineqlin に
% 線形不等式 A を、LAMBDA.eqlin に線形等式 Aeq を、LAMBDA.lower に 
% LB を、LAMBDA.upper に UB を設定しています。


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2003/05/01 13:02:44 $
