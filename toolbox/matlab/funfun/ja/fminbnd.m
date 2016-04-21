%FMINBND スカラで範囲の制約を付けた非線形関数の最小化
% X = FMINBND(FUN,x1,x2)は、x0から始め、x1 < X < x2の範囲で、(通常、
% M-ファイルで記述された)FUNに記述された関数の局所的な最小値に対応する
% Xを出力します。FUNは、スカラ入力 X を受け入れ、X でのスカラ関数値 F 
% を出力します。
%
%   X = FMINBND(FUN,x1,x2,OPTIONS) は、デフォルトの最適パラメータの代わり
% に、OPTIMSET関数で作成されたOPTIONS構造体の値を使って最小化を行います。
% 詳しくは、OPTIMSETを参照してください。FMINBNDは、つぎのオプション、
% Display, TolX, MaxFunEval, MaxIter, FunValCheck, OutputFcn を使います。
%
% X = FMINBND(FUN,x1,x2,OPTIONS,P1,P2,...) は、目的関数 FUN(X,P1,P2,...)
% に渡す付加的な引数を指定します(オプションを設定しない場合は、
% プレイスホルダとして、OPTIONS = [] を利用してください)。
%
% [X,FVAL] = FMINBND(...)は、値 X での目的関数 FUN の値 FVAL を出力します。
%
% [X,FVAL,EXITFLAG] = FMINBND(...) は、また、FMINBND の終了状態を記述する 
% EXITFLAG を出力します。
%   EXITFLAG が、
%     1 の場合、FMINBNDは、OPTIONS.TolFunをベースにした解 X に収束しました。
%     0 の場合、関数評価、または、繰り返しの最大数に到達しました。
%    -1 の場合、最適化は、ユーザにより終了されます。
%    -2 の場合、境界が inconsistent (すなわち、ax > bx) です。
%
% [X,FVAL,EXITFLAG,OUTPUT] = FMINBND(...) は、OUTPUT.iterations の中の繰り
% 返し回数、OUTPUT.funcCount の中の関数評価の数、OUTPUT.algorithm の中の
% アルゴリズム名、OUTPUT.message の中の終了メッセージを含んだ構造体
% OUTPUT も出力します。
%
% 例題
% FUN は、@:を使って設定することができます。
%        X = fminbnd(@cos,3,4)
% は、数桁までπを計算し、終了時にメッセージを表示します。

%  [X,FVAL,EXITFLAG] = fminbnd(@cos,3,4,optimset('TolX',1e-12,'Display','off'))
% は、πを12桁まで計算し、出力を表示しないで、x での関数値を出力し、
% EXITFLAG に1を出力します。
%
% FUN は、anonymous function でも設定することができます。
%        f = @(x) sin(x)+3;
%        x = fminbnd(f,2,5)
%
% 参考 OPTIMSET, FMINSEARCH, FZERO, FUNCTION_HANDLE.

%   Reference: "Computer Methods for Mathematical Computations",
%   Forsythe, Malcolm, and Moler, Prentice-Hall, 1976.

%   Original coding by Duane Hanselman, University of Maine.
%   Copyright 1984-2004 The MathWorks, Inc.
