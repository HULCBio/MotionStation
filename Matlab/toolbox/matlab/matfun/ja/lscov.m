%LSCOV 既知の共分散を使った最小二乗解法
% X = LSCOV(A,B) は、線形方程式系 A*X = B に対する通常の最小二乗解
% を出力します。すなわち、X は、二乗誤差 (B - A*X)'*(B - A*X)の和を
% 最小にする、N×1 ベクトルです。ここで、A は、M×N, B は、M×1 です。
% B は、M×K 行列にもなり、LSCOV は、B の各列に対する解を出力します。
% rank(A) < N の場合、LSCOV は、"basic solution" を得るために、X の 
% 要素の可能な最大数をゼロと置きます。
%
% X = LSCOV(A,B,W) は、W を正の実数の重みをもつベクトルの長さ M として、
% 線形システム A*X = B に対する重み付きの最小二乗解を出力します。すなわち、
% X は、(B - A*X)'*diag(W)*(B - A*X) を最小にします。W は、通常は
% カウント または inverse variances のいずれかを含みます。
%
% X = LSCOV(A,B,V)は、M×M 実対称正定値行列 V について、
% V に比例する共分散行列をもつ線形系 A*X = B に対する一般化最小二乗解を
% 出力します。すなわち、X は、(B - A*X)'*inv(V)*(B - A*X) を最小化します。
%
% より一般に、V は、半正定になることが可能であり、LSCOV は、
% 制約のある最小化問題の解である、X を出力します。
%
%      minimize E'*E subject to A*X + T*E = B
%        E,X
%
% ここで、T*T' = V です。V が半正定である場合、この問題は、B が、A と V
% と矛盾のない(すなわち、[A T] の列の空間にある)場合に限り、解をもちます。
% そうでない場合、LSCOV は、エラーを出力します。
%
% デフォルトでは、LSCOV は、V の Cholesky 分解を計算し、実際は、
% 問題を通常の最小二乗に変換するために、その要素を変換します。
% しかし、LSCOV が V が半正定であると決定する場合、V の変換を避ける、
% 直交分解アルゴリズムを使用します。
%
% X = LSCOV(A,B,V,ALG) により、V が行列の場合、X の計算に使用される
% アルゴリズムを明示して選択することができます。
% LSCOV(A,B,V,'chol') は、V の Cholesky 分解を使用します。
% LSCOV(A,B,V,'orth') は、直交分解を使用し、 V がill-conditioned または
% 非正則の場合により適当ですが、計算量がより多くなります。
%
% [X,STDX] = LSCOV(...) は、X の 推定標準誤差を出力します。
% A がランク落ちの場合、STDX は、X のゼロの要素に対応する要素にゼロを
% 含みます。
%
% [X,STDX,MSE] = LSCOV(...) は、平均二乗誤差を出力します。
%
% [X,STDX,MSE,S] = LSCOV(...) は、X の推定共分散行列を出力します。
% A がランク落ちの場合、S は、X の ゼロの要素に対応する行と列に
% ゼロを含みます。
% LSCOV は、右辺が複数あるとき(すなわち、size(B,2) > 1)にコールされる場合、
% S を出力できません。
%
% A と V がフルランクの場合、これらの量についての標準形は、つぎのように
% なります。
%
%      X = inv(A'*inv(V)*A)*A'*inv(V)*B
%      MSE = B'*(inv(V) - inv(V)*A*inv(A'*inv(V)*A)*A'*inv(V))*B./(M-N)
%      S = inv(A'*inv(V)*A)*MSE
%      STDX = sqrt(diag(S))
%
% しかし、LSCOV は、より高速でより安定な手法を使用し、ランク落ちの
% 場合にも適用することもできます。
%
% LSCOV は、B の共分散行列がスケール因子までのみ、既知であると仮定します。
% MSE は、未知のスケール因子の推定であり、LSCOV は、適切に、出力 S と 
% STDX をスケールします。しかし、V が B の共分散行列であることが既知の
% 場合、そのスケーリングは必要ありません。この場合、適切な推定をするため
% には、S と STDX をそれぞれ、1/MSE と sqrt(1/MSE) によりリスケールする
% 必要があります。
%
% 参考 SLASH, LSQNONNEG, QR.

%   参考文献:
%      [1] Paige, C.C. (1979) "Computer Solution and Perturbation
%          Analysis of Generalized Linear Leat Squares Problems",
%          Mathematics of Computation 33(145):171-183.
%      [2] Golub, G.H. and Van Loan, C.F. (1996) Matrix Computations,
%          3rd ed., Johns Hopkins University Press.
%      [2] Goodall, C.R. (1993) "Computation using the QR Decomposition",
%          in Computational Statistics, Vol. 9 of Handbook of Statistics,
%          edited by C.R. Rao, North-Holland, pp. 492-494.
%      [4] Strang, G. (1986) Introduction to Applied Mathematics,
%          Wellesley-Cambridge Press, pp. 398-399.

%   Copyright 1984-2003 The MathWorks, Inc.
