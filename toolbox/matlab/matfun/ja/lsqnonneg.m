% LSQNONNEG   非負制約をもった線形最小二乗
% 
% X = LSQNONNEG(C,d) は、X > =  0 の制約に従って、NORM(C*X - d) を最小
% にするベクトル X を出力します。ここで、C と d は共に実数でなければなり
% ません。
%
% X = LSQNONNEG(C,d,X0) は、all(X0 > 0)の場合、出発点として X0 を使いま
% す｡それ以外では、デフォルトを使います。デフォルトの出発点は原点です
% (デフォルトは、X0 == [] の場合または入力引数が2つしか設定されていない場
% 合のどちらかで 使われます)。 
%
% X = LSQNONNEG(C,d,X0,OPTIONS) は、デフォルトの最適パラメータの代わり
% に、関数 OPTIMSET で作成されたOPTIONS構造体の値を使って最小化を行
% います。詳しくは、OPTIMSET を参照してください。使用するオプションは、
% Display、TolXです(デフォルトの許容範囲 TolX は、
% 10*MAX(SIZE(C))*NORM(C,1)*EPS が使用されます)。
%
% [X,RESNORM] = LSQNONNEG(...) は、残差の平方2ノルムnorm(C*X-d)^2 も
% 出力します。
% 
% [X,RESNORM,RESIDUAL] = LSQNONNEG(...) は、残差 C*X-d も出力します。
% 
% [X,RESNORM,RESIDUAL,EXITFLAG] = LSQNONNEG(...) は、LSQNONNEGの
% 終了条件を記述する EXITFLAG を出力します。 
% 
% EXITFLAG が
%   1 の場合、LSQNONNEG は、解X に収束します。
%   0 の場合、繰り返し回数が設定値を超えていることを意味します。許容範囲
%   (OPTIONS.TolX)を大きくすることで、解が求まるかもしれません。
% 
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT] = LSQNONNEG(...) は、
% OUTPUT.iterations で得られるステップ数、OUTPUT.algorithm で使われた
% アルゴリズムのタイプ、および、OUTPUT.message の終了メッセージを含む、
% OUTPUT 構造体を出力します。
%
% [X,RESNORM,RESIDUAL,EXITFLAG,OUTPUT,LAMBDA] = LSQNONNEG(...)
% は、双対ベクトル LAMBDA を出力します。ここで、X(i) が(およそ) 0のとき、
% LAMBDA(i) <=0 で、X(i) > 0 のとき LAMBDA(i) は(およそ）0です。
% 
% 参考：LSCOV, SLASH.

%   Copyright 1984-2004 The MathWorks, Inc. 
