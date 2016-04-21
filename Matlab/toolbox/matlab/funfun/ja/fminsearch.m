%FMINSEARCH 多次元の制約ないの非線形最小化(Nelder-Mead法）
% X = FMINSEARCH(FUN,X0)は、初期設定ベクトルX0の近傍でFUNに記述された
% 関数の極小値の位置を示すベクトルXを出力します。FUNは、入力 X を
% 受け入れ、X で計算したスカラ関数値 F を出力します。X0 は、スカラ、
% ベクトル、行列のいずれでも構いません。
%
% X = FMINSEARCH(FUN,X0,OPTIONS)  は、デフォルトの最適パラメータの代
% わりに、OPTIMESET 関数で作成された OPTIONS 構造体の値を使って最小
% 化を行います。詳しくは、OPTIMSET を参照してください。FMINSEARCH は、
% オプション Display, TolX, TolFun, MaxFunEvals, MaxIter, FunValCheck,
% OutputFcn を使用します。 
%
% X = FMINSEARCH(FUN,X0,OPTIONS,P1,P2,...)  は、目的関数 
% F=FUN(X,P1,P2,...) に渡す付加的な引数を指定します。
% デフォルト値を利用するにはOPTIONSに空行列を指定してください
% (オプションを設定しない場合は、プレイスホルダとして OPTION = [] 
% を利用してください)。
%
% [X,FVAL] =  FMINSEARCH(...) は、値 X での目的関数 FUN の値 FVAL を
% 出力します。
%
% [X,FVAL,EXITFLAG] = FMINSEARCH(...) は、FMINSEARCHの終了状態を記述する
% 文字列EXITFLAGを出力します。
%   EXITFLAG が、
%     1の場合、FMINSEARCH は解 X で収束しています。
%   　0の場合、関数評価計算の最大数または繰り返し数に達しています。
%    -1の場合、最適化はユーザにより終了されます。
%
% [X,FVAL,EXITFLAG,OUTPUT] = FMINSEARCH(...) は、OUTPUT.iterations の中の繰り
% 返し回数、OUTPUT.funcCount の中の関数評価の数、OUTPUT.algorithm の中の
% アルゴリズム名、OUTPUT.message の中の終了メッセージを含んだ構造体
% OUTPUT も出力します。
%
% 例題
% FUN は、@ を使って、設定することができます。
%        X = fminsearch(@sin,3)
% は、値3の近傍で、SIN の最小値を求めます。この場合、SIN は、X でのスカ
% ラ関数値 SIN も出力します。
%
% FUN は、anonymous functionを使って、設定することができます。
%        X = fminsearch(@(x) norm(x),[1;2;3])
% は、 [0;0;0] の近傍で最小値を出力します。
%
% FMINSEARCH は、Nelder-Mead シンプレックス(直接)法を使っています。
%
% 参考 OPTIMSET, FMINBND, FUNCTION_HANDLE.

% Reference: Jeffrey C. Lagarias, James A. Reeds, Margaret H. Wright,
% Paul E. Wright, "Convergence Properties of the Nelder-Mead Simplex
% Method in Low Dimensions", SIAM Journal of Optimization, 9(1):
% p.112-147, 1998.

%   Copyright 1984-2004 The MathWorks, Inc.
