% FGOALATTAIN   多目的ゴール到達最適化問題を解きます。
%
% X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT) は、FUN（通常はM-ファイル FUN.M)で
% 設定される目的関数(F)を、Xを変化させることにより、ゴール（GOAL）に到達
% させます。
%
% ゴールは、WEIGHT に従って、重み付けられます。
% 
%            min     { LAMBDA :  F(X)-WEIGHT.*LAMBDA< = GOAL } 
%          X,LAMBDA  
%
% 関数 'FUN' は、目的値 F を値 X で計算した値、つまり、F = feval(FUN,X) 
% を出力します。X0 は、スカラ、ベクトル、行列のいずれでも構いません。
% 
% X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B) は、線形不等式 A*X <= B の制約
% のもとで、ゴール到達問題を解きます。
%
% X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B,Aeq,Beq) は、線形方程式 Aeq*X =
% Beq の制約のもとで、ゴール到達問題を解きます。
%
% X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B,Aeq,Beq,LB,UB)  は、設計変数 X 
% の上下限を設定します。これにより、VLB < =  X < =  VUB の範囲の解を求め
% ることになります。範囲の設定を行なわない場合は、LB と UB に空行列を
% 設定してください。また、 X(i) に下限を設定しない場合は、LB(i) = -Inf で
% 上限を設定しない場合は、UB(i) = Inf と設定してください。
% 
% X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B,Aeq,Beq,LB,UB,NONLCON) は、
% NONLCON(通常は、NONLCON.M と名付けた M-ファイル)で定義した制約のもとで、
% ゴール到達問題を解きます。関数 NONLCON は、feval: 
% [C, Ceq] = feval(NONLCON,X) の型で、コールされ、それぞれ、非線形の
% 不等式制約と等式制約を表わす C と Ceq ベクトルを出力します。FGOALATTAIN 
% は、C(X)< = 0 と Ceq(X) = 0 になるように最適化します。
%
% X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS) 
% は、デフォルトの最適化パラメータを関数 OPTIMSET を使って、構造体 OPTIONS 
% の中の値と置き換えて、最小化します。詳細は、OPTIMSET を参照してください。
% 使用可能なオプションは、Display, TolX, TolFun, TolCon, DerivativeCheck, 
% GradObj, GradConstr, MaxFunEvals, MaxIter, MeritFunction, 
% GoalsExactAchieve, Diagnostics, DiffMinChange, DiffMaxChangeです。
% オプション GradObj を使って、2つの出力引数をもった関数 FUN をコールし、
% 2番目の出力引数 G に、点 X での関数の偏微分係数 df/dX を設定することが
% できます。[F,G] = feval(FUN,X) の型でコールします。GradConstr オプション
% を使って、NONLCON に4つの出力引数をもつ [C,Ceq,GC,GCeq] = feval(NONLCON,X)
% をコールすることができます。ここで、GC は、不等号制約ベクトル C の偏微分
% 係数、GCeq は、等式制約ベクトル Ceq の偏微分係数です。オプションを設定
% しない場合は、OPTIONS = [] を使用してください。
%
% X = FGOALATTAIN(FUN,X0,GOAL,WEIGHT,A,B,Aeq,Beq,LB,UB,NONLCON,OPTIONS,P1,P2,...) 
% は、問題に関連したパラメータ P1,P2,... を、直接、関数 FUN や NONLCON に
% 渡します。たとえば、feval(FUN,X,P1,P2,...) や feval(NONLCON,X,P1,P2,...) 
% の型で使います。引数 A, B, Aeq, Beq, LB, UB, NONLCON, OPTIONS にデフォルト
% 値を使用する場合は、空行列を渡してください。
%
% [X,FVAL] = FGOALATTAIN(FUN,X0,...) は、解 X での目的関数値 FUN も出力
% します。
%
% [X,FVAL,ATTAINFACTOR] = FGOALATTAIN(FUN,X0,...) は、解 X での到達ファクタ
% も出力します。ATTAINFACTOR が負の場合、ゴールは、過到達になります。
% また、正の場合、欠到達になります。
%
% [X,FVAL,ATTAINFACTOR,EXITFLAG] = FGOALATTAIN(FUN,X0,...) は、FGOALATTAIN 
% の終了状況を示す文字列 EXITFLAG を出力します。
% EXITFLAG は、つぎの意味を表わします。
%    > 0 の場合、FGOALATTAIN は、解 X に収束しています。
%    0   の場合、関数計算の繰り返し回数が、設定している最大回数に達して
%                います。
%    < 0 の場合、FGOALATTAIN は、解に収束しませんでした。
%   
% [X,FVAL,ATTAINFACTOR,EXITFLAG,OUTPUT] = FGOALATTAIN(FUN,X0,...) は、
% 繰り返し回数 OUTPUT.iterations、関数の計算回数 OUTPUT.funcCount、使用
% したアルゴリズム OUTPUT.algorithm を含んだ構造体 OPTPUT を出力します。
% 
% [X,FVAL,ATTAINFACTOR,EXITFLAG,OUTPUT,LAMBDA] = FGOALATTAIN(FUN,X0,...)
% は、解 X での Lagrange 乗数 LAMBDA を出力します。LAMBDA 構造体は、LB 
% に LAMBDA.lower を、UB に LAMBDA.upper を、非線形不等式に 
% LAMBDA.ineqnonlin を、非線形等式に LAMBDA.eqnonlin を設定しています。
%
% 詳細は、M-ファイル FGOALATTAIN.M　を参照してください。
%
% 参考 : OPTIMSET, OPTIMGET.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2003/05/01 13:01:27 $
