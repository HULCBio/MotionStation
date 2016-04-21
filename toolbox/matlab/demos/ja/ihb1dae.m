%IHB1DAE  保存則からのスティッフな微分代数方程式 (DAE)
%
% IHB1DAE は、fully implicit system f(t,y,y') = 0 として表わされた
% スティッフな微分代数方程式 ( stiff differential-algebraic equation 
% (DAE) system )の解のデモを実行します。
%   
% Robertson problem は、HB1ODEにコードされたように、スティッフな
% 常微分方程式(系）を解くコードに対する古典的なテスト問題です。
% 問題は、つぎのものです。
%
%         y(1)' = -0.04*y(1) + 1e4*y(2)*y(3)
%         y(2)' =  0.04*y(1) - 1e4*y(2)*y(3) - 3e7*y(2)^2
%         y(3)' =  3e7*y(2)^2
%
%
% 定常状態に対する、初期条件 y(1) = 1, y(2) = 0, y(3) = 0 をもつとして
% 解かれます。
%
% これらの微分方程式は、問題をDAEとして定式化するために使用
% できる線形の保存則を満たします。
%
%         0 =  y(1)' + 0.04*y(1) - 1e4*y(2)*y(3)
%         0 =  y(2)' - 0.04*y(1) + 1e4*y(2)*y(3) + 3e7*y(2)^2
%         0 =  y(1)  + y(2) + y(3) - 1
%
% この問題は、LSODI [1] の序文において例として用いられます。
% 矛盾のない初期条件は自明ですが、推定 y(3) = 1e-3 が、初期化のテストに
% 使用されます。対数スケールは、長時間間隔の解をプロットするために
% 適しています。y(2) は小さく、その主な変化は比較的短時間で起こります。
% 従って、LSODI の序文は、このコンポーネントについて、はるかに小さい絶対許容
% 誤差を指定します。また、他の要素とともにプロットする場合、1e4 が乗算されます。% コードの通常の出力は、この要素の振る舞いをはっきりとは示しません。従って、
% この目的のために、追加の出力が指定されます。
%   
%   [1]  A.C. Hindmarsh, LSODE and LSODI, two new initial value ordinary
%        differential equation solvers, SIGNUM Newsletter, 15 (1980), 
%        pp. 10-11.
%   
% 参考 ODE15I, ODE15S, ODE23T, ODESET, HB1ODE, HB1DAE, @.

%   Mark W. Reichelt and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
