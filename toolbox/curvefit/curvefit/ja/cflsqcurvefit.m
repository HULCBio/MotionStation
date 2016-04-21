% LSQCURVEFIT  非線形最小二乗問題の解法
% LSQCURVEFIT は、つぎの型の問題を解きます。
%   min  sum {(FUN(X,XDATA)-YDATA).^2}  
%    X                                  
%                                       
% ここで、X, XDATA, YDATA, FUN から出力される値は、ベクトル、または、
% 行列です。
%
% X=LSQCURVEFIT(FUN,X0,XDATA,YDATA) は、X0 をスタート点として、データ 
% YDATA にFUN の中の非線形方程式を(非線形の意味で)最適近似する係数 X を
% 求めます。FUN は、X と XDATA を入力として受け、関数値 F からなるベク
% トル(または、行列)を出力します。ここで、F は YDATA と同じサイズで、X 
% と XDATA で計算されたものです。
% 
% 注意：FUN は、FUN(X,XDATA) を出力し、二乗和 sum(FUN(X,XDATA).^2)) で
% はありません。(FUN(X,XDATA) は、アルゴリズムの中で、陰的に二乗され、
% 和を計算されます) 
%
% X=LSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB) は、設計変数 X に下限と上限を
% 設定し、そのために、解は、LB <= X <= UB のレンジになります。範囲を設定
% しない場合、LB と UB には、空行列を使ってください。X(i) に下限制約を設
% 定しない場合は、LB(i) = -Inf をX(i) に上限制約を設定しない場合は、
% UB(i) = Inf を設定してください。
%
% X=LSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB,OPTIONS) は、関数 OPTIMSET で作
% 成した構造体 OPTIONS の中の値を使って、デフォルト設定値を書き換えて、最
% 小化を行います。詳細は、OPTIMSET を参照してください。使用可能なオプショ
% ンは、Display, TolX, TolFun, DerivativeCheck, Diagnostics, Jacobian, 
% JacobMult, JacobPattern, LineSearchType, LevenbergMarquardt, MaxFunEvals, 
% MaxIter, DiffMinChange, DiffMaxChange, LargeScale, MaxPCGIter, Precond-
% BandWidth, TolPCG, TypicalX です。Jacobian オプションを使って、2番目の
% 出力引数 J が、点 X での Jacobian 行列であるように FUN を設定することが
% できます。FUN は、X が長さ n のときに、m 要素のベクトル F を出力する場
% 合、J は、m 行 n 列の行列になります。ここで、J(i,j) は、F(i) の x(j)に
% 関する偏微分です(Jacobian J は、F の勾配の転置です)。
%
% X=LSQCURVEFIT(FUN,X0,XDATA,YDATA,LB,UB,OPTIONS,P1,P2,..) は、関数 FUN:
% FUN(X,XDATA,P1,P2,..) に、問題に依存したパラメータ P1,P2,... を直接渡
% します。OPTIONS に空行列を渡すと、デフォルト値が使われます。
%
% [X,RESNORM]=LSQCURVEFIT(FUN,X0,XDATA,YDATA,...) は、X での残差の2ノル
% ムsum {(FUN(X,XDATA)-YDATA).^2} を出力します。
%
% [X,RESNORM,RESIDUAL]=LSQCURVEFIT(FUN,X0,...) は、解 X での残差 FUN(X,
% XDATA)-YDATA の値を出力します。
%
% [X,RESNORM,RESIDUAL,EXITFLAG]=LSQCURVEFIT(FUN,X0,XDATA,YDATA,...) は、
% LSQCURVEFIT の終了条件を記述した文字列 EXITFLAG を出力します。
% 
%   EXITFLAG は、値に依り、つぎの意味を示します。
%      > 0 ：LSQCURVEFIT は、解 X に収束します。
%      0   ：関数の計算回数が、設定した回数に達しました。
%      < 0 ：LSQCURVEFIT は、解に収束しません。
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT]=LSQCURVEFIT(FUN,X0,XDATA,YDATA,...)
% は、構造体 OUTPUT を出力し、その要素として、OUTPUT.iterations に繰り返
% し回数、OUTPUT.funcCount に関数計算の回数、OUTPUT.algorithm に使用した
% アルゴリズム、OUTPUT.cgiterations にCG イタレーションの回数、OUTPUT.fi-
% rstorderopt に(使用している場合)線形最適性を出力します。
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA]=
% LSQCURVEFIT(FUN,X0,XDATA,YDATA,...) は、解で、Lagrangian 乗数を LAMB-
% DA に、LB については、LAMBDA.lower を、UB については、LAMBDA.upper を
% 出力します。
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN]=
% LSQCURVEFIT(FUN,X0,XDATA,YDATA,...) は、X での FUN の Jacobian を出力
% します。
%
% 例題
%     FUN は、@ を使って指定できます。
%        xdata = [5;4;6];
%        ydata = 3*sin([5;4;6])+6;
%        x = lsqcurvefit(@myfun, [2 7], xdata, ydata)
%
% ここで、MYFUN は、つぎのような MATLAB 関数です。
%
%       function F = myfun(x,xdata)
%       F = x(1)*sin(xdata)+x(2);
%
% FUN は、inline オブジェクトでも構いません。
%
%       fun = inline('x(1)*sin(xdata)+x(2)','x','xdata');
%       x = lsqcurvefit(fun,[2 7], xdata, ydata)
%
% 参考   OPTIMSET, LSQNONLIN, FSOLVE, @, INLINE.

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
