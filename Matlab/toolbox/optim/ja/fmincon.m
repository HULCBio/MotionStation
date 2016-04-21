% FMINCON   制約付き多変数関数の最小化
%
% FMINCON は、つぎの形式の問題を解きます。
% F(X) を、つぎの制約のもとで、
% 　　　　　　A*X  <= B, Aeq*X  = Beq (線形制約)
%       　　　C(X) <= 0, Ceq(X) = 0   (非線形制約)
%       　　　LB <= X <= UB            
% で、X を変化させて、最小化します。
% 
% X = FMINCON(FUN,X0,A,B) は、初期値を X0 として、線形不等式制約 A*X <= B 
% の制約のもとで、FUN により表される関数を最小化する X を求めます。X0 は、
% スカラ、ベクトル、または、行列です。
%
% X = FMINCON(FUN,X0,A,B,Aeq,Beq) は、A*X <= B と同様に線形等式制約 
% Aeq*X = Beq の制約のもとで FUN を最小化します(不等式制約がない場合は、
% A=[] と B=[] として設定します)。
%
% X = FMINCON(FUN,X0,A,B,Aeq,Beq,LB,UB) は、設計変数 X の上下限の範囲を
% 与えます。この場合は、解は、LB <= X <= UB の範囲に入ります。範囲による
% 制約がない場合、LB と UB に空行列を設定してください。X(i) に下限がない
% 場合、LB(i) = -Inf と設定し、X(i) に上限がない場合、UB(i) = Inf と設定
% します。
%
% X = FMINCON(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON) は、NONLCON で定義された
% 制約のもとで最小化します。関数 NONLCON は、ベクトル C と Ceq によって
% 表される非線形不等式と非線形等式の値を出力します。FMINCON は、C(X) <= 0 
% と Ceq(X) = 0 となる  FUN を最小化します(範囲の制約がない場合、LB=[] と 
% UB=[] として設定します)。
%
% X = FMINCON(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS) は、OPTIMSET 関
% 数によって、作成した引数を OPTIONS 構造体をデフォルトオプションパラメータ
% の代わりに与えます。詳細は、OPTIMSET を参照してください。ここでは、
% Display, TolX, TolFun, TolCon, DerivativeCheck, Diagnostics, GradObj, 
% GradConstr, Hessian, MaxFunEvals, MaxIter, DiffMinChange and DiffMaxChange,
% LargeScale, MaxPCGIter, PrecondBandWidth, TolPCG, TypicalX, Hessian, 
% HessMult, HessPattern パラメータが使われます。
% 
% オプション GradObj を使って、２番目の出力引数 G に点 X での関数の偏微分
% 係数 df/dX を出力する FUN を設定します。オプション Hessian を使って、
% 3番目の出力引数 H に、点 X での関数の2階微分(ヘシアン)を出力する FUN 
% を設定します。ヘシアンは、大規模問題のみに使用され、ラインサーチ法では
% 使用されません。オプション GradConstr を使って、NONLCON が、3番目の
% 出力引数に GC 、4番目の引数に GCeq をもつように設定します。ここで、GC は
% 不等号制約ベクトル C の偏微分係数、GCeq は、等式制約ベクトル Ceq の偏微分
% 係数です。オプションを設定しない場合は、OPTIONS = [] を使用してください。
% 
% X = FMINCON(FUN,X0,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS,P1,P2,...)  は、
% 問題に関連したパラメータ P1,P2,... を、直接、関数 FUN や NONLCON に
% 渡します。たとえば、feval(FUN,X,P1,P2,...) や feval(NONLCON,X,P1,P2,...)
% の型で使います。引数 A, B, Aeq, Beq, OPTIONS, LB, UB, NONLCON にデフォルト
% 値を使用する場合は、空行列を渡してください。
%
% [X,FVAL] = FMINCON(FUN,X0,...) は、解 X での目的関数値 FUN も出力します。
%
% [X,FVAL,EXITFLAG] = FMINCON(FUN,X0,...) は、FMINCON の終了状況を示す
% フラグ EXITFLAG を出力します。
% EXITFLAG は、つぎの意味を表わします。
%    > 0 の場合、FMINCON は、解 X に収束しています。
%    0   の場合、関数計算の繰り返し回数が、設定している最大回数に達して
%                います。
%    < 0 の場合、FMINCON は、解に収束しませんでした。
% 
% [X,FVAL,EXITFLAG,OUTPUT] = FMINCON(FUN,X0,...) は、繰り返し回数 
% OUTPUT.iterations、関数の計算回数 OUTPUT.funcCount、使用したアルゴリズム 
% OUTPUT.algorithm(使用した場合)CG 繰り返しの回数を OUTPUT.cgiterations 
% (使用した場合)一次の最適値 OUTPUT.firstorderopt を構造体 OUTPUT に出力
% します。
%
% [X,FVAL,EXITFLAG,OUTPUT,LAMBDA] = FMINCON(FUN,X0,...)  は、解 X での 
% Lagrange 乗数 LAMBDA を出力します。LAMBDA 構造体は、LAMBDA.lower に LB
% を、LAMBDA.upper に UB を、LAMBDA.ineqnonlin に非線形不等式を、
% LAMBDA.eqnonlin には非線形等式を設定しています。
%
% [X,FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD] = FMINCON(FUN,X0,...) は、解 X で
% の関数 FUN の勾配値も出力します。
%
% [X,FVAL,EXITFLAG,OUTPUT,LAMBDA,GRAD,HESSIAN] = FMINCON(FUN,X0,...) は
% 解 X での関数 FUN の HESSIAN 値を出力します。
%　
% 例題：
% FUN は、@:X = fmincon(@hump,...) を使って設定できます。この場合、
% F = humps(x) は、x での HUMPS 関数のスカラ関数値 F を出力します。
% 
% FUN は、インラインオブジェクトとしても表現できます。
% 
% X = fmincon(inline('3*sin(x(1))+exp(x(2)'),[1;1],[],[],[],[],[0 0])
% 
% は、X = [0;0] を出力します。
% 
% 参考 : OPTIMSET, FMINUNC, FMINBND, FMINSEARCH, @, INLINE.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2003/05/01 12:59:59 $
