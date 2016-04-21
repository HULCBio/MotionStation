% LINPROG   線形計画問題
%
% X = LINPROG(f,A,b) は、つぎの形式の線形計画問題を解きます。:
%        
% 制約条件:  A*x <= b の制約のもとで、min f'*x を x について、最小化します。
%  
% X = LINPROG(f,A,b,Aeq,beq) は、等式制約 Aeq*x = beq のもとで、上の問題
% を解きます。
% 
% X = LINPROG(f,A,b,Aeq,beq,LB,UB) は、設計変数 X の上下限の範囲を与えます。
% この場合は、解は、LB <= X <= UB の範囲に入ります。範囲による制約がない
% 場合、LB と UB に空行列を設定してください。X(i) に下限がない場合、
% LB(i) = -Inf と設定し、X(i) に上限がない場合、UB(i) = Inf と設定します。
%
% X = LINPROG(f,A,b,Aeq,beq,LB,UB,X0) は、初期点 X0 とします。このオプション
% は、active-set アルゴリズムを使用するときのみ利用できます。デフォルトの
% 内点アルゴリズムは、いくつかの空でない初期値を無視します。
%
% X = LINPROG(f,A,b,Aeq,Beq,LB,UB,X0,OPTIONS) は、OPTIMSET 関数によって
% 引数が作成された OPTIONS 構造体をデフォルトオプションパラメータと置き
% 換えることができます。詳細は、OPTIMSET を参照してください。ここでは、
% Display, Diagnostics, TolFun, LargeScale, MaxIter パラメータが使われます。
% カレントで、LargeScale が、'off' の場合、パラメータ Display には、
% 'final' と 'off' のみが使用できます(LargeScale が 'on' のときは、'iter' 
% のみが使用できます)。
%
% [X,FVAL] = LINPROG(f,A,b) は、X で目的関数値 FVAL = f'*X を出力します。
%
% [X,FVAL,EXITFLAG] = LINPROG(f,A,b)  は、LINPROG の終了状況を示す文字列
% EXITFLAG を出力します。
% EXITFLAG は、つぎの意味を表わします。:
%    > 0 の場合、LINPROG  は、解 X に収束しています。
%    0   の場合、関数計算の繰り返し回数が、設定している最大回数に達して
%                います。
%    < 0 の場合、LINPROG は、解に収束しませんでした。
%
% [X,FVAL,EXITFLAG,OUTPUT] = LINPROG(f,A,b) は、繰り返し回数 
% OUTPUT.iterations、関数の計算回数 OUTPUT.funcCount、使用したアルゴリズム 
% OUTPUT.algorithm、(使用した場合)CG 繰り返しの回数  OUTPUT.cgiterations を
% 構造体 OUTPUT に出力します。
%
% [X,FVAL,EXITFLAG,OUTPUT,LAMBDA] = LINPROG(f,A,b) は、解における
% ラグランジュ(Lagrangian)乗数 LAMBDA を出力します。: LAMBDA.ineqlin に
% 線形不等式 A を、LAMBDA.eqlin に線形等式 Aeq を、LAMBDA.lower に 
% LB を、LAMBDA.upper に UB を設定しています。
%   
% 注意：
% LINPROG の大規模法(デフォルト)は、primal-dual 法を使います。主問題と
% 双対問題は、共に収束可能です。主問題、双対問題、または、両方のいずれかが
% 実行可能であるというメッセージは、適宜与えられます。主問題の標準的な
% 形式は、以下の通りです。
% 
%              min f'*x    制約条件 A*x = b, x >= 0
% 
% 双対問題は、以下の形式です。
% 
%              max b'*y    制約条件 A'*y + s = f, s >= 0


%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2003/05/01 13:02:00 $
