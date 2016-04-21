% FSEMINF   半無限制約付き最適化問題を解きます。
%
% FSEMINF は、つぎの型の問題を解きます。区間内に存在するすべての w に
% 対して、x を変化させて、{ F(x) | C(x)< = 0 , Ceq(X) = 0 , PHI(x,w)< = 0 } 
% の F(x) を最小化します。
%
% X = FSEMINF(FUN,X0,NTHETA,SEMINFCON) は、初期値を X0 として、SEMINFCOM 
% (通常、M-ファイル)で生成されたNTHETA 半無限制約のもとで、関数 FUN に
% より表される関数を最小化する X を求めます。関数 FUN は、feval を使って、
% F = feval(FUN,X) の型でコールされたとき、X に関するスカラ関数値 F を
% 出力します。関数 SEMINFCON は、非線形不等式制約 C、非線形等式制約 Ceq、
% 各区間で推定される NTHETA 半無限不等式制約 PHI_1, PHI_2, ..., PHI_NTHETA 
% に関するベクトルを出力します。つぎの型で、使用します。
% [C,Ceq,PHI_1,PHI_2,...,PHI_NTHETA,S] = feval(SEMINFCON,X,S)：S は、
% 推奨するサンプル間隔で、使用しても、しなくても構いません。
%
% X = FSEMINF(FUN,X0,NTHETA,SEMINFCON,A,B) は、線形不等式 A*X < =  B を
% 満足しようとします。
%
% X = FSEMINF(FUN,X0,NTHETA,SEMINFCON,A,B,Aeq,Beq) は、線形等式 Aeq*X = Beq 
% も満足しようとします(不等式が存在しない場合、A = [] と B = [] を設定して
% ください)。
%
% X = FSEMINF(FUN,X0,NTHETA,SEMINFCON,A,B,Aeq,Beq,LB,UB) は、設計変数 X 
% の上下限の範囲を与えます。この場合、解は、LB <= X <= UB の範囲に入ります。
% 範囲による制約がない場合、LB と UB に空行列を設定してください。X(i) に
% 下限がない場合、LB(i) = -Inf と設定し、X(i) に上限がない場合、UB(i) = Inf 
% と設定します。
%
% X = FSEMINF(FUN,X0,NTHETA,SEMINFCON,A,B,Aeq,Beq,LB,UB,OPTIONS) は、
% OPTIMSET 関数によって、引数が作成された OPTIONS 構造体をデフォルト
% オプションパラメータと置き換えます。詳細は、OPTIMSET を参照してください。
% ここでは、Display, TolX, TolFun, TolCon, DerivativeCheck, Diagnostics,
% GradObj,  MaxFunEvals, MaxIter, DiffMinChange and DiffMaxChange パラメータ
% が使われます。オプション GradObj を使って、2つの出力引数をもった関数 
% FUN をコールし、2番目の出力引数 G に、点 X での関数の偏微分係数 df/dX 
% を設定することができます。[F,G] = feval(FUN,X) の型でコールします
%
% X = FSEMINF(FUN,X0,NTHETA,SEMINFCON,A,B,Aeq,Beq,LB,UB,OPTIONS,P1,P2,.)
% は、問題に関連したパラメータ P1,P2,... を、直接、関数 FUN や SEMINFCON に
% 渡します。たとえば、feval(FUN,X,P1,P2,...) や feval(SEMINFCON,X,P1,P2,...)
% の型で使います。オプションを設定しない場合、OPTIONS を設定する位置に、
% [] を設定してください。
%
% [X,FVAL] = FSEMINF(FUN,X0,NTHETA,SEMINFCON,...) は、解 X での目的関数値 
% FUN も出力します。
%
% [X,FVAL,EXITFLAG] = FSEMINF(FUN,X0,NTHETA,SEMINFCON,...) は、FSEMINF の
% 終了状況を示す文字列 EXITFLAG を出力します。
% 
% EXITFLAG は、つぎの意味を表わします。
%    > 0 の場合、FSEMINF は、解 X に収束しています。
%    0   の場合、関数計算の繰り返し回数が、設定している最大回数に達して
%                います。
%    < 0 の場合、FSEMINF は、解に収束しませんでした。
% 
% [X,FVAL,EXITFLAG,OUTPUT] = FSEMINF(FUN,X0,NTHETA,SEMINFCON,...) は、
% 繰り返し回数 OUTPUT.iterations、関数の計算回数 OUTPUT.funcCount、使用
% したアルゴリズム OUTPUT.algorithm を構造体 OUTPUT に出力します。
%
% [X,FVAL,EXITFLAG,OUTPUT,LAMBDA] = FSEMINF(FUN,X0,NTHETA,SEMINFCON,...)
% は、解 X での Lagrange 乗数を出力します。LAMBDA 構造体は、LAMBDA.lower
% に LB を、LAMBDA.upper に UB を、LAMBDA.ineqnonlin に非線形不等式を、
% LAMBDA.eqnonlin に非線形等式を設定しています。
% 
% 例題
% FUN と SEMINFCOM は、@ を使って、設定することができます。
%
%        x = fseminf(@myfun,[2 3 4],3,@myseminfcon)
%
% ここで、MYFUN は、つぎのように表わせる MATLAB 関数です。
% 
%    function F = myfun(x)
%    F = x(1)*cos(x(2))+x(3)^3:
% 
% また、MYSEMINFCON も、つぎのように表わせる MATLAB 関数です。
% 
%       function [C,Ceq,PHI1,PHI2,S] = myseminfcon(X,S)
%       C = ... ;     % C と Ceq を計算するコード：空行列でも可能です。
%       Ceq = ... ;
%       if isnan(S(1,1))
%          S = ... ; % S は ntheta 行2列の行列です。
%       end
%       PHI1 = ... ;       % PHI を計算するコード
%       PHI2 = ... ;
% 　　　　　
% 参考 : OPTIMSET, @, FGOALATTAIN, LSQNONLIN.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2003/05/01 13:00:07 $
