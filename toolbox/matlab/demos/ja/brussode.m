% BRUSSODE   化学反応のモデリングのスティッフな問題(the Brusselator).
% 
% パラメータN > =  2を使って、グリッド点の数を指定します。結果のシステム
% の結果は、2N個の方程式で構成されます。デフォルトでは、Nは20 です。Nが
% 増加すると、問題はスティッフ、かつスパース度は高くなります。この問題の
% ヤコビアンは、スパース定数行列です(帯域は5です)。
%   
% プロパティ 'JPattern' は、Jacobian df/dy の中の非ゼロの位置を示す、0と
% 1から構成されるスパース行列を使ったソルバを与えるために使うものです。
% デフォルトでは、ODE Suite のスティフなソルバは、フル行列と同じような
% 数値的な Jacobian を作成します。しかし、スパース性を示すパターンが与え
% られた場合、ソルバはそれを使って、スパース行列として数値的な 
% Jacobian を作成します。スパースパターンを与えることは、Jacobian を作成
% するために必要な関数値の算出回数を非常に減らし、積分を速くすることにな
% ります。BRUSSODE 問題に対して、2N 行 2N 列のJacobian 行列を計算する
% するために、4回の関数の実行が必要です。
%   
% 'Vectorized' プロパティを設定することは、関数 f がベクトル化されている
% ことを示しています。
%   
% E. Hairer and G. Wanner, Solving Ordinary Differential Equations II,
% Stiff and Differential-Algebraic Problems, Springer-Verlag, Berlin,
% 1991, pp. 5-8.
%   
% 参考：ODE15S, ODE23S, ODE23T, ODE23TB, ODESET, @.

