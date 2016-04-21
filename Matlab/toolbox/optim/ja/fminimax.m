% FMINIMAX   多変数関数のミニマックス問題を解きます。
%
% FMINMAX は、つぎの問題を解きます。
% (max {FUN(X} )   ここで、FUN と X は、ベクトル、または、行列です。
%   X
%
% X = MINIMAX(FUN,X0) は、X0 を初期値として、FUN(通常はM-ファイル FUN.M)
% で定義される関数のミニマックス解 X を求めます。FUN は、X で計算した
% 関数値 F のベクトルを出力します。X0 は、スカラ、ベクトル、または、
% 行列です。
%
% X = FMINIMAX(FUN,X0,A,B) は、線形不等式制約 A*X <= B のもとでミニマックス
% 問題を解きます。
%
% X = FMINIMAX(FUN,X0,A,B,Aeq,Beq) は、線形等式制約 Aeq*X = Beq のもとで
% ミニマックス問題を解きます(不等式制約がない場合には、A=[],B=[] と設定
% します)。
% 
% X = FMINIMAX(FUN,X0,A,B,Aeq,Beq,LB,UB) は、設計変数 X の上下限の範囲を
% 定義します。ここで、解は、LB <= X <= UB の範囲に入ります。範囲の制約が
% ない場合、LB と UB に空行列を設定してください。X(i) に下限がない場合、
% LB(i) = -Inf とし、X(i) に上限がない場合、UB(i) = Inf と設定します。
% 
% X = FMINIMAX(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON) は、NONLCON で定義された
% 制約のもとで、ミニマックス問題を解きます。関数 NONLCON は、feval に
% よって、[C,Ceq] = feval(NONLCON,X) のようにコールされるとき、ベクトル 
% C と Ceq によって表される非線形不等式と非線形等式の値を出力します。
% FMINMAX は、C(X)< = 0 と Ceq(X) = 0 となるように最適化します。
%
% X = FMINIMAX(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS)  は、OPTIMSET 
% 関数によって、引数が作成された OPTIONS 構造体をデフォルトオプション
% パラメータと置き換えます。詳細は、OPTIMSET を参照してください。ここでは
% Display, TolX, TolFun, TolCon, DerivativeCheck, GradObj, GradConstr, 
% MaxFunEvals, MaxIter, MeritFunction, MinAbsMax, Diagnostics, 
% DiffMinChange and DiffMaxChangeパラメータが使われます。オプション 
% GradObj を使って、2つの出力引数をもった関数 FUN をコールし、2番目の
% 出力引数 G に点 X での関数の偏微分係数 df/dX を設定することができます。
% [F,G] = feval(FUN,X) の型でコールします。GradConstr オプションを使って、
% NONLCON に4つの出力引数をもつ [C,Ceq,GC,GCeq] = feval(NONLCON,X) を
% コールすることができます。ここで、GC は、不等号制約ベクトル C の偏微分
% 係数、GCeq は、等式制約ベクトル Ceq の偏微分係数です。オプションを設定
% しない場合は、OPTIONS = [] を使用してください。
% 
% X = FMINIMAX(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS,P1,P2,...)  は、
% 問題に関連したパラメータ P1,P2,... を、直接、関数 FUN や NONLCON に
% 渡します。たとえば、feval(FUN,X,P1,P2,...) や feval(NONLCON,X,P1,P2,...) 
% の型で使います。引数 A, B, Aeq, Beq, LB, UB, NONLCON, OPTIONS にデフォルト
% 値を使用する場合は、空行列を渡してください。
%
% [X,FVAL] = FMINIMAX(FUN,X0,...) は、解 X での目的関数値 FUN も出力します。
% つぎの型 FVAL = feval(FUN,X) で計算します。
%
% [X,FVAL,MAXFVAL] = FMINIMAX(FUN,X0,...) は、解 X で、
% MAXFVAL = max { FUN(X) } を出力します。
%
% [X,FVAL,MAXFVAL,EXITFLAG] = FMINIMAX(FUN,X0,...) は、FMINIMAX の終了
% 状況を示す文字列 EXITFLAG を出力します。
% EXITFLAG は、つぎの意味を表わします。
%    > 0 の場合、FMINIMAX は、解 X に収束しています。
%    0   の場合、関数計算の繰り返し回数が、設定している最大回数に達して
%                います。
%    < 0 の場合、FMINIMAX は、解に収束しませんでした。
%   
% [X,FVAL,MAXFVAL,EXITFLAG,OUTPUT] = FMINIMAX(FUN,X0,...) は、繰り返し
% 回数 OUTPUT.iterations、関数の計算回数 OUTPUT.funcCount、使用した
% アルゴリズム OUTPUT.algorithm を出力します。
%
% [X,FVAL,MAXFVAL,EXITFLAG,OUTPUT,LAMBDA] = FMINIMAX(FUN,X0,...)  は、
% 解 X での Lagrange 乗数 LAMBDA を出力します。LAMBDA 構造体は、LB に 
% LAMBDA.lower　を、UB に LAMBDA.upper を、非線形不等式に LAMBDA.ineqnonlin
% を、非線形等式に LAMBDA.eqnonlin を設定しています。
%
% 例題
% FUN は、@ を使って設定できます。:
%
%        x = fminimax(@myfun,[2 3 4])
%
% ここで、MYFUN は、つぎのような MATLAB 関数です。:
% 
%   function F = myfun(x)
%   F = cos(x);
% 
% FUN は、インラインオブジェクトでも設定できます。
% 
%   fun = inline('sin(3*x)')
%   x = fminimax(fun,[2 5]);
% 
% 参考 : OPTIMSET, @, INLINE, FGOALATTAIN, LSQNONLIN.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2003/05/01 13:00:01 $
