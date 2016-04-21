%FZERO  1変数関数のゼロ点の検出
% 
% X = FZERO(FUN,X0)は、X0の近傍でFUNのゼロ点を求めます。FUNは、実数
% スカラ入力 X を受け入れ、X での実数スカラ関数値 F を出力します。FZERO
% により出力される値Xは、(FUNが連続の場合は)FUNの符号が変わる近傍点
% か、または解が求まらない場合は、NaNを出力します。
%
% X = FZERO(FUN,X0)について、Xが長さ2のベクトルであるとき、X0は FUN(X0
% (1))の符号がFUN(X0(2))の符号と異なるような区間であると仮定します。そう
% でない場合は、エラーが生じます。区間に関する保証を与えてFZEROをコール
% すると、FZEROはFUNの符号が変化する近傍点の値を出力します。
%
% X = FZERO(FUN,X0)について、X0がスカラ値であるとき、X0を初期推定値とし
% て使います。FZEROは、FUNに対する符号の変化と、X0を含んだ区間を探し
% ます。このような区間が見つからなければ、NaNが出力されます。この場合、
% Inf、NaNまたは複素数値が求められるまでサーチ区間が拡張されると、サーチ
% は終了します。
%
% X = FZERO(FUN,X0,OPTIONS)は、デフォルトの最適パラメータの代わりに、
% OPTIMSET関数で作成されたOPTIONS構造体の値を使って最小化を行います。
% 詳しくは、OPTIMSETを参照してください。使用するオプションは、Display、
% TolXです。オプションを設定しない場合は、OPTIONS = [] を利用してくださ
% い。
%
% X = FZERO(FUN,X0,OPTIONS,P1,P2,...)は、関数F = feval(FUN,X,P1,P2,...)
% に渡す付加的な引数を指定します。OPTIONSのデフォルト値を利用するには、
% 空行列を指定してください。
%
% [X,FVAL] = FZERO(FUN,...)は、値Xでの目的関数FUNの値FVALを出力します。
%
% [X,FVAL,EXITFLAG] = FZERO(...)は、FZEROの終了状態を記述する文字列
% EXITFLAGを出力します。
% 
% EXITFLAGは、つぎのようになります。
%    >0 : FZEROはゼロ点Xを求めました。
%    <0 : 区間内で関数の符号が変化する部分がない、または符号が変化する区
%         間で、サーチ中にNaNまたはInfが検出された、または符号が変化する
%         区間で、サーチ中に複素数関数値が検出された。
%
% [X,FVAL,EXITFLAG,OUTPUT] = FZERO(...)は、OUTPUT.iterationsに繰り返
% し回数をもつ構造体OUTPUTを出力します。
%
% 例題
%     FUN は、@:を使って設定することもできます。
%        X = fzero(@sin,3)
%     は、πを出力します。
%        X = fzero(@sin,3,optimset('disp','iter')) 
% は、デフォルトのトレランスを使ってπを出力し、繰り返し計算の情報を表
% 示します。
%
%     FUN は、anonymous function でも設定できます。
%        X = fzero(@(x) sin(3*x),2)
%
% 制限
%        X = fzero(@(x) abs(x)+1, 1) 
% は、実数軸のどんな位置でも符号が変化しない(ゼロにならない)ので、 NaN 
% を出力します。
%        X = fzero(@tan,2)
% は、点 X の近傍でこの関数が不連続なので、X で関数の符号が変化するよ
% うに見えるため、1.5708 近傍で X を出力します。
%
% 参考 ROOTS, FMINBND, FUNCTION_HANDLE.

%   Copyright 1984-2004 The MathWorks, Inc. 
