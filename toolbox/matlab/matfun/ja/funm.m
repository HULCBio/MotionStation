%FUNM  一般的な行列関数の計算
% F = FUNM(A,FUN) は、正方行列 A で、関数 FUN を評価します。
% FUN(X,K) は、ベクトル X で評価される FUN により表わされる、関数の K階
% 導関数を出力する必要があります。
% MATLAB 関数 EXP, LOG, COS, SIN, COSH, SINH は、FUN として渡すことができます。
% すなわち、FUNM(A,@EXP), FUNM(A,@LOG), FUNM(A,@COS), FUNM(A,@SIN),
% FUNM(A,@COSH), FUNM(A,@SINH) とすることができます。
% 行列の平方根に対して、代わりに、SQRTM(A) を使用してください。
% 行列指数については、A に依存して、EXPM(A) と FUNM(A,@EXP) のいずれかが、
% より正確になります。
%
% FUN により表わされる関数は、無限大の収束半径をもつ Taylor 級数を
% もつ必要があります。
%
%   例題:
% FUNM を1度コールして、A での関数 EXP(X)+COS(X) を計算するためには、
% つぎを使用してください。
%       F = funm(A,@fun_expcos)
% ここで、
%       function f = fun_expcos(x,k)
%       % X での EXP+COS の k 階導関数を出力
%       g = mod(ceil(k/2),2);
%       if mod(k,2)
%          f = exp(x) + sin(x)*(-1)^g;
%       else
%          f = exp(x) + cos(x)*(-1)^g;
%       end
%
% F = FUNM(A,FUN,options) は、アルゴリズムのパラメータを構造体オプション
% の値に設定します。
%   options.Display:  表示レベル
%                     [ {off} | on | verbose ]
%   options.TolBlk:   blocking Schur 型に対する許容値
%                     [ 正のスカラー {0.1} ]
%   options.TolTay:   対角ブロックの Taylor級数を評価するための
%                     終了許容値
%                     [ 正のスカラー {eps} ]
%   options.MaxTerms: Taylor 級数項の最大数
%                     [ 正の整数 {250} ]
%   options.MaxSqrt:  対数を計算する場合、inverse scaling and
%                     squaring method で計算される平方根の最大数
%                     [ 正の整数 {100} ]
%   options.Ord:      Schur 型, T の指定した順序
%                     T(i,i)が置かれるブロックのインデックス、options.Ord(i)
%                     をもつ長さ LENGTH(A) のベクトル
%                     [ integer vector {[]} ]
%
% F = FUNM(A,FUN,options,P1,P2,...) は、付加的な入力 P1,P2,... を 
% FEVAL(FUN,X,K,P1,P2,...)のように、関数に渡します。
% オプションが設定されていない場合、プレイスホルダとして、options = [] を
% 使用してください。
%
% [F,EXITFLAG] = FUNM(...) は、FUNM の終了条件を記述するスカラーの EXITFLAG 
% を出力します。
%   EXITFLAG = 0: アルゴリズムの正常終了
%   EXITFLAG = 1: 1つまたは複数の Taylor 級数が収束しませんでした。
%                 ただし、計算された F は、正確です。
% 注意: R13 や 以前のバージョンは、第2出力引数に計算量が多く不正確になること
% が多い誤差評価を出力していたため、この点で異なります。
%
% [F,EXITFLAG,output] = FUNM(...) は、つぎをもつ構造体 output を出力します。
%   output.terms(i):  i 番目のブロックを評価する場合に使用される Taylor 級数
%                     の数、または、対数の場合の平方根の数
%   output.ind(i):   ブロックを指定するセル配列: 
%                    re-ordered Schur 型 T の(i,j)ブロックは、
%                    T(output.ind{i},output.ind{j}) です。
%   output.ord:      ORDSCHUR に渡される順序
%   output.T:        re-ordered Schur 型
% Schur 型が対角行列の場合、
%   output = struct('terms',ones(n,1),'ind',{1:n})
%
% 参考 EXPM, SQRTM, LOGM, @.

%   参考文献:
%   P. I. Davies and N. J. Higham.                                        
%   A Schur-Parlett algorithm for computing matrix functions.             
%   SIAM J. Matrix Anal. Appl., 25(2):464-485, 2003. 
%
%   Nicholas J. Higham
%   Copyright 1984-2004 The MathWorks, Inc.

