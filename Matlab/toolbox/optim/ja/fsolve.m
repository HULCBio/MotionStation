% FSOLVE   最小二乗法を使って、非線形方程式を解きます。
%
% FSOLVE は、つぎの形式の問題を解きます。
% 
% F(X) = 0    ここで、F と X は、ベクトルまたは行列です。   
%
% X = FSOLVE(FUN,X0) は、初期値を X0 として、FUN により表される関数を
% 最小化する X を求めます。関数 FUN は、通常、M-ファイルで、F = FUN(X) 
% の型でコールされたとき、X の特定の値に対する方程式の値を出力します。
%
% X = FSOLVE(FUN,X0,OPTIONS) は、OPTIMSET 関数によって、引数が作成された
% OPTIONS 構造体をデフォルトオプションパラメータと置き換えます。詳細は、
% OPTIMSET を参照してください。ここでは、Display, TolX, TolFun, 
% DerivativeCheck, Diagnostics, Jacobian, JacobMult, JacobPattern, 
% LineSearchType, LevenbergMarquardt, MaxFunEvals, MaxIter, DiffMinChange, 
% DiffMaxChange, LargeScale, MaxPCGIter, PrecondBandWidth, TolPCG, TypicalX 
% パラメータが使われます。オプション Jacobian を使って、2つの出力引数を
% もった関数 FUN をコールし、2番目の出力引数 J に、Jacobian 行列を設定
% することができます。[F,J] = feval(FUN,X) の型でコールします。FUN は、
% X が長さ n のときに m 要素のベクトル(行列) F を出力する場合、J は、m行
% n列の行列になります。ここで、J(i,j) は、F(i) の x(j) による偏微分係数
% です(Jacobian J は、F の勾配を転置したものです)。
%
% X = FSOLVE(FUN,X0,OPTIONS,P1,P2,...)  は、問題に関連したパラメータ 
% P1,P2,... を、直接、関数 FUN に渡します。たとえば、FUN(X,P1,P2,...) の型
% で使います。引数 OPTIONS にデフォルト値を使用する場合は、空行列を渡して
% ください。
%
% [X,FVAL] = FSOLVE(FUN,X0,...) は、解 X での目的関数値も出力します。
%
% [X,FVAL,EXITFLAG] = FSOLVE(FUN,X0,...) は、FSOLVE の終了状況を示す文字列
% EXITFLAG を出力します。
% EXITFLAG は、つぎの意味を表わします。
%    > 0 の場合、FSOLVE は、解 X に収束しています。
%    0   の場合、関数計算の繰り返し回数が、設定している最大回数に達して
%                います。
%    < 0 の場合、FSOLVE は、解に収束しませんでした。
%
% [X,FVAL,EXITFLAG,OUTPUT] = FSOLVE(FUN,X0,...) は、繰り返し回数 
% OUTPUT.iterations、関数の計算回数 OUTPUT.funcCount、使用したアルゴリズム 
% OUTPUT.algorithm、(使用した場合)CG 繰り返しの回数 OUTPUT.cgiterations、
% (使用した場合)一次の最適値 OUTPUT.firstorderopt を構造体 OUTPUT に出力
% します。
%
% [X,FVAL,EXITFLAG,OUTPUT,JACOB] = FSOLVE(FUN,X0,...)  は、解 X での関数
% FUN のJacobianを出力します。
% 
% 例題：
% FUN は、@ を使って、設定することができます。
%
%        x = fsolve(@myfun,[2 3 4],optimset('Display','iter'))
%
%ここで、MYFUN は、つぎのような MATLAB 関数です。
%
%       function F = myfun(x)
%       F = sin(x);
%
% FUN は、インラインオブジェクトでも設定できます。
%
%       fun = inline('sin(3*x)');
%       x = fsolve(fun,[1 4],optimset('Display','off'));
%
% 参考：OPTIMSET, LSQNONLIN, @, INLINE.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2003/05/01 13:00:09 $
