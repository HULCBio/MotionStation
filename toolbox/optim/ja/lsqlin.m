% LSQLIN   制約付き最小二乗問題を解きます。
%
% X = LSQLIN(C,d,A,b) は、つぎの型をした最小二乗問題を解きます。
%
% A*x < =  b の制約のもとで、0.5*(NORM(C*x-d)).^2 を x に関して最小化し
% ます。ここで、C は、m行n列の行列です。
%
% X = LSQLIN(C,d,A,b,Aeq,beq) は、(等号の制約条件をもつ)問題を最小二乗的
% に解きます。
%
% A*x < =  b と Aeq*x = beq の制約のもとで、0.5*(NORM(C*x-d)).^2 をx に
% ついて、最小化します。
%
% X = LSQLIN(C,d,A,b,Aeq,beq,LB,UB) は、設計変数 X の上下限の範囲を与え
% ます。この場合は、解は、LB <= X <= UB の範囲に入ります。範囲による制約
% がない場合、LB と UB に空行列を設定してください。X(i) に下限がない場合
% LB(i) = -Inf と設定し、X(i) に上限がない場合、UB(i) = Inf と設定します。
%
% X = LSQLIN(C,d,A,b,Aeq,beq,LB,UB,X0) は、初期値を X0 とします。
%
% X = LSQLIN(C,d,A,b,Aeq,beq,LB,UB,X0,OPTIONS) は、OPTIMSET 関数によって
% 引数が作成された OPTIONS 構造体をデフォルトオプションパラメータと置き
% 換えて、最小化します。詳細は、OPTIMSET を参照してください。ここでは、
% Display, Diagnostics, TolFun, LargeScale, MaxIter, JacobMult, 
% PrecondBandWidth, TypicalX, TolPCG, MaxPCGIter パラメータが使われます。
% カレントで、'final' と 'off' のみが、パラメータ Display に対して使われ
% ます('iter' は、使われません)。
%
% X=LSQLIN(C,d,A,b,Aeq,beq,LB,UB,X0,OPTIONS,P1,P2,...) は、
% OPTIMSET('JacobMult',JMFUN) が設定されるとき、問題に依存するパラメータ 
% P1,P2,... を直接 JMFUN 関数に渡します。JMFUN は、ユーザによって与え
% られます。デフォルト値を使うために、A, b, Aeq, beq, LB, UB, XO, OPTIONS 
% に空行列を渡してください。
%
% [X,RESNORM] = LSQLIN(C,d,A,b) は、X での残差の二乗 2 ノルム値 
% norm(C*X-d)^2 を出力します。
%
% [X,RESNORM,RESIDUAL] = LSQLIN(C,d,A,b) は、残差 C*X-d を出力します。
%
% [X,RESNORM,RESIDUAL,EXITFLAG] = LSQLIN(C,d,A,b) は、LSQLIN の終了状況
% を示す文字列 EXITFLAG を出力します。
% EXITFLAG は、つぎの意味を表わします。:
%    > 0 の場合、LSQLIN は、解 X に収束しています。
%    0   の場合、関数計算の繰り返し回数が、設定している最大回数に達して
%                います(大規模法でのみ生じます)。
%    < 0 の場合、問題に制約がない、非可解領域、または、LSQLIN は、解に収
%                束しませんでした。
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = LSQLIN(C,d,A,b) は、繰り返し
% 回数 OUTPUT.iterations、使用したアルゴリズム OUTPUT.algorithm、(使用した
% 場合)CG 繰り返しの回数  OUTPUT.cgiterations 、(使用した場合)一次の最適値
% OUTPUT.firstorderopt を構造体 OUTPUT に出力します。
%
% [x,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA] = LSQLIN(C,d,A,b)  は、解 
% X でのラグランジュ(Lagrangian)乗数 LAMBDA を出力します。: 
% LAMBDA.ineqyalities に線形不等式 C を、LAMBDA.eqlin に線形等式 Ceq を、
% LAMBDA.lower に LB を、LAMBDA.upper に UB を設定しています。


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2003/05/01 13:02:07 $
%   Mary Ann Branch 9-30-96.
