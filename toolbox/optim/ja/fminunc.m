% FMINUNC   多変数関数の最小化
%
% X = FMINUNC(FUN,X0) は、初期値を X0 として、FUN により表される関数を
% 最小化するX を求めます。FUN は、X を入力として、X での関数値 F を出力
% します。X0 は、スカラ、ベクトル、または、行列です。
% 
% X = FMINUNC(FUN,X0,OPTIONS) は、OPTIMSET 関数によって、引数が作成された
% OPTIONS 構造体をデフォルトオプションパラメータを置き換えます。詳細は、
% OPTIMSET を参照してください。ここでは、Display, TolX, TolFun, 
% DerivativeCheck, Diagnostics, GradObj,HessPattern, LineSearchType, 
% Hessian, HessMult, HessUpdate, MaxFunEvals, MaxIter, DiffMinChange, 
% DiffMaxChange, LargeScale, MaxPCGIter, PrecondBandWidth, TolPCG, TypicalX 
% パラメータが使われます。オプション GradObj を使って、2つの出力引数を
% もった関数 FUN をコールし、2番目の出力引数 G に、点 X での関数の偏微分
% 係数 df/dX を設定することができます。[F,G] = feval(FUN,X) の型でコール
% します。オプション Hessian を使って、3つの出力引数をもつ FUN をコール
% することができます。2番目の引数 G は、解 X での関数 df/dX の偏微分係数
% で、3番目の引数 H は、2階微分(Hessian)になります。[F,G,H] = feval(FUN,X) 
% の型でコールします。Hessian は、大規模スケール問題でのみ使われ、ライン
% サーチ法では、使われません。
%
% X = FMINUNC(FUN,X0,OPTIONS,P1,P2,...)  は、問題に関連したパラメータ 
% P1,P2,... を、直接、関数 FUN に渡します。たとえば、feval(FUN,X,P1,P2,...) 
% の型で使います。引数 OPTIONS にデフォルト値を使用する場合は、空行列を
% 渡してください。
%
% [X,FVAL] = FMINUNC(FUN,X0,...) は、解 X での目的関数値も出力します。
%
% [X,FVAL,EXITFLAG] = FMINUNC(FUN,X0,...) は、FMINUNC の終了状況を示す
% 文字列  EXITFLAG を出力します。
% EXITFLAG は、つぎの意味を表わします。
%    > 0 の場合、FMINUNC は、解 X に収束しています。
%    0   の場合、関数計算の繰り返し回数が、設定している最大回数に達して
%                います。
%    < 0 の場合、FMINUNC は、解に収束しませんでした。
%
% [X,FVAL,EXITFLAG,OUTPUT] = FMINUNC(FUN,X0,...) は、繰り返し回数 
% OUTPUT.iterations、関数の計算回数 OUTPUT.funcCount、使用したアルゴリズム 
% OUTPUT.algorithm、(使用した場合)CG 繰り返しの回数 OUTPUT.cgiterations
% (使用した場合)一次の最適値 OUTPUT.firstorderopt を構造体 OUTPUT を
% 出力します。
%
% [X,FVAL,EXITFLAG,OUTPUT,GRAD] = FMINUNC(FUN,X0,...) は、解 X での関数 
% FUN の勾配値を出力します。
%
% [X,FVAL,EXITFLAG,OUTPUT,GRAD,HESSIAN] = FMINUNC(FUN,X0,...) は、解 X 
% での目的関数 FUN のHessian値を出力します。
% 
% 例題 
% FUN は、@ を使って、設定することができます。
%
%        X = fminunc(@myfun,2)
%
% ここで、MYFUN は、つぎのように表わされる MATLAB 関数です。
% 
%        function f = myfun(x)
%         f = sin(x)+3;
%
% 与えられた勾配を使って、関数を最小化するために、勾配が2番目の引数と
% するように MYFUN を変更します。
% 
%        function [f,g] =  myfun(x)
%         f = sin(x) + 3;
%         g = cos(x);
% 
% そして、(OPTIMSET を使って)OPTIONS.GradObj を 'on' に設定し、勾配値を
% 使用できるようにします。
% 
%        options = optimset('GradObj','on');
%        x = fminunc('myfun',4,options);
%
% FUN をインラインオブジェクトを使って設定することもできます。
% 
%        x = fminunc(inline('sin(x)+3'),4);
% 
% 参考 : OPTIMSET, FMINSEARCH, FMINBND, FMINCON, @, INLINE.


%   Copyright 1990-2003 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2003/05/01 13:00:05 $
%   Andy Grace 7-9-90.
