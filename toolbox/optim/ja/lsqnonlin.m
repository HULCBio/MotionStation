% LSQNONLIN   非線形最小二乗問題を解きます。
%
% LSQNONLIN は、つぎの型の問題を解きます。
% sum {FUN(X).^2} を、X に関して最小化します。ここで、X と FUN で出力
% される値は、ベクトルでも、行列でも構いません。
%
% X = LSQNONLIN(FUN,X0) は、行列 X0 を初期値として、FUN に記述される関数
% の二乗和を最小にします。FUN は、通常、M-ファイルで記述され、F = FUN(X) 
% の形で、目的関数のベクトルを出力します。注意：FUN は、FUN(X) を出力し
% 二乗和 sum(FUN(X).^2))を出力するものではありません(FUN(X) は、アルゴ
% リズムの中で、インプリシットに二乗され、和が計算されています)。
%
% X = LSQNONLIN(FUN,X0,LB,UB) は、設計変数 X の上下限の範囲を与えます。
% この場合は、解は、LB <= X <= UB の範囲に入ります。範囲による制約がない
% 場合、LB と UB に空行列を設定してください。X(i) に下限がない場合、
% LB(i) = -Inf と設定し、X(i) に上限がない場合、UB(i) = Inf と設定します。
% 
% X = LSQNONLIN(FUN,X0,LB,UB,OPTIONS) は、OPTIMSET 関数によって、引数が
% 作成された OPTIONS 構造体をデフォルトオプションパラメータと置き換えて
% 最小化します。詳細は、OPTIMSET を参照してください。ここでは、 パラメータ
% が使われます。オプション Jacobian を使って、2つの出力引数をもった関数 
% FUN をコールし、2番目の出力引数 J に、Jacobian 行列を設定することが
% できます。[F,J] = feval(FUN,X) の型でコールします。FUN が、X が長さ  
% n のとき、m 要素のベクトル(行列)を出力する場合、J は、m行n列の行列に
% なります。ここで、J(i,j) は、F(i) の x(j) による偏微分係数です(Jacobian 
% J は、F の勾配を転置したものです)。
%
% X = LSQNONLIN(FUN,X0,LB,UB,OPTIONS,P1,P2,..)  は、問題に関連したパラメータ 
% P1,P2,... を、直接、関数 FUN に渡します。たとえば、FUN(X,P1,P2,...) の
% 型で使います。引数 OPTIONS にデフォルト値を使用する場合は、空行列を
% 渡してください。
%
% [X,RESNORM] = LSQNONLIN(FUN,X0,...) は、X での残差の2ノルム sum(FUN(X).^2) 
% を出力します。
%
% [X,RESNORM,RESIDUAL] = LSQNONLIN(FUN,X0,...) は、X での残差値 
% RESIDUAL = FUN(X) を出力します。
%
% [X,RESNORM,RESIDUAL,EXITFLAG] = LSQNONLIN(FUN,X0,...) は、LSQNONLIN の
% 終了状況を示す文字列 EXITFLAG を出力します。
% EXITFLAG は、つぎの意味を表わします。:
%    > 0 の場合、LSQNONLIN は、解 X に収束しています。
%    0   の場合、関数計算の繰り返し回数が、設定している最大回数に達して
%                います。
%    < 0 の場合、LSQNONLIN は、解に収束しませんでした。
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = LSQNONLIN(FUN,X0,...) は、繰り
% 返し回数 OUTPUT.iterations、関数の計算回数 OUTPUT.funcCount、使用した
% アルゴリズム OUTPUT.algorithm、(使用した場合)CG 繰り返しの回数 
% OUTPUT.cgiterations 、(使用した場合)一次の最適値 OUTPUT.firstorderopt 
% を構造体 OUTPUT に出力します。
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA] = LSQNONLIN(FUN,X0,...) は、
% 解 X でのラグランジュ(Lagrangian)乗数 LAMBDA を出力します。:
% LAMBDA.lower にLB を、LAMBDA.upper にUB を設定しています。
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN] = LSQNONLIN(FUN,X0,...)
% は、解 X での関数 FUN の Jacobian 値を出力します。
%
% 例題
% FUN は、@ を使って設定することができます。:
%        x = lsqnonlin(@myfun,[2 3 4])
%
% ここで、MYFUN は、つぎのように記述された MATLAB 関数です。
%
%       function F = myfun(x)
%       F = sin(x);
%
% FUN は、インラインオブジェクトでも設定することができます。
%
%       fun = inline('sin(3*x)')
%       x = lsqnonlin(fun,[1 4]);
%
% 参考 : OPTIMSET, LSQCURVEFIT, FSOLVE, @, INLINE.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2003/05/01 13:02:09 $
