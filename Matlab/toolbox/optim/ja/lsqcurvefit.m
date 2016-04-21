% LSQCURVEFIT   非線形最小二乗問題を解きます。
%
% LSQCURVEFIT は、つぎの型の問題を解きます。
% sum {(FUN(X,XDATA)-YDATA).^2} をXを変化させて、最小化します。
% ここで、X, XDATA, YDATA, FUN の出力値は、ベクトルまたは行列です。
%
% X = LSQCURVEFIT(FUN,X0,XDATA,YDATA) は、初期値を X0 とし、FUN で定義
% する非線形関数をデータ YDATA に、最小二乗的に最適近似する係数 X を求め
% ます。FUN は、X と XDATA を入力し、関数値 F のベクトル(または、行列)を
% 出力します。ここで、F は、YDATA と同じサイズで、X と XDATA で計算した
% ものです。注意：FUN は、FUN(X,XDATA) を出力し、二乗和の 
% sum(FUN(X,XDATA).^2) を出力しません(FUN(X,XDATA) は、アルゴリズムの
% 中で、自動的に和を計算し、二乗されます)。
%
% X = LSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB) は、設計変数 X の上下限の
% 範囲を与えます。この場合は、解は、LB <= X <= UB の範囲に入ります。
% 範囲による制約がない場合、LB と UB に空行列を設定してください。X(i) に
% 下限がない場合、LB(i) = -Inf と設定し、X(i) に上限がない場合、UB(i) = Inf 
% と設定します。
% 
% X=LSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB,OPTIONS) は、OPTIMSET 関数に
% よって、引数が作成された OPTIONS 構造体をデフォルトオプションパラメータ
% を置き換えて、最小化します。詳細は、OPTIMSET を参照してください。ここでは、
% Display, TolX, TolFun, DerivativeCheck, Diagnostics, Jacobian, JacobMult, 
% JacobPattern, LineSearchType, LevenbergMarquardt, MaxFunEvals, MaxIter, 
% DiffMinChange and DiffMaxChange, LargeScale, MaxPCGIter, PrecondBandWidth, 
% TolPCG, TypicalX パラメータが使われます。オプション Jacobian を使って、
% 2つの出力引数をもった関数 FUN をコールし、2番目の出力引数 J に、Jacobian
% 行列を設定することができます。[F,J] = feval(FUN,X) の型でコールします。
% FUN が、X が長さ n の場合、m 要素のベクトル(行列)を出力する場合、J は、
% m行n列の行列になります。ここで、J(i,j) は、F(i) の x(j) による偏微分
% 係数です(Jacobian J は、F の勾配を転置したものです)。
%
% X = LSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB,OPTIONS,P1,P2,..)  は、問題に
% 関連したパラメータ P1,P2,... を、直接、関数 FUN に渡します。たとえば、
% FUN(X,P1,P2,...)の型で使います。引数 OPTIONS にデフォルト値を使用する
% 場合は、空行列を渡してください。
%
% [X,RESNORM]=LSQCURVEFIT(FUN,X0,XDATA,YDATA,...)  は、X での残差の2ノルム
% sum {(FUN(X,XDATA)-YDATA).^2} を出力します。
%
% [X,RESNORM,RESIDUAL] = LSQCURVEFIT(FUN,X0,...) は、解 X での残差の値 
% FUN(X,XDATA)-YDATA を出力します。
%
% [X,RESNORM,RESIDUAL,EXITFLAG] = LSQCURVEFIT(FUN,X0,XDATA,YDATA,...) は、
% LSQCURVEFIT の終了状況を示す文字列 EXITFLAG を出力します。
% EXITFLAG は、つぎの意味を表わします。:
%    > 0 の場合、LSQCURVEFIT は、解 X に収束しています。
%    0   の場合、関数計算の繰り返し回数が、設定している最大回数に達して
%                います。
%    < 0 の場合、LSQCURVEFIT は、解に収束しませんでした。
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = LSQCURVEFIT(FUN,X0,XDATA,YDATA,...) 
% は、繰り返し回数 OUTPUT.iterations、関数の計算回数 OUTPUT.funcCount、
% 使用したアルゴリズム OUTPUT.algorithm、(使用した場合)CG 繰り返しの回数 
% OUTPUT.cgiterations 、(使用した場合)一次の最適値 OUTPUT.firstorderopt 
% を構造体 OUTPUT に出力します。
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA] = LSQCURVEFIT(FUN,X0,XDATA,YDATA,) 
% は、解 X でのラグランジュ(Lagrangian)乗数 LAMBDA を出力します。:
% LAMBDA.lower に LB を、LAMBDA.upper に UB を設定しています。
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN] = LSQCURVEFIT(FUN,X0,XDATA,YDATA,...) 
% は、解 X での関数 FUN のJacobian値を出力します。
%
% 例題
% FUN は、@ を使って設定することができます。:
% 　　   xdata = [5;4;6];
%        ydata = 3*sin([5;4;6])+6;
%        x = lsqcurvefit(@myfun, [2 7], xdata, ydata)
%
% ここで、MYFUN は、つぎの MATLAB 関数です。
%
%       function F = myfun(x,xdata)
%       F = x(1)*sin(xdata)+x(2);
%
% FUN は、インラインオブジェクトで設定することもできます。:
%
%       fun = inline('x(1)*sin(xdata)+x(2)','x','xdata');
%       x = lsqcurvefit(fun,[2 7], xdata, ydata)
%
% 参考 : OPTIMSET, LSQNONLIN, FSOLVE, @, INLINE.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2003/05/01 13:02:04 $
%   Mary Ann Branch 8-22-96.
