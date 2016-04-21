% PADESS   Simulink/Jacobians と共に使用するスパース Pade 近似
% 
% [abcd_elements, Ir, Jc] = PADESS(DelayTime, Order, needs_scalar_expansion);
%
% は、abcd_elements の中に、スパース線形モデルの非ゼロ要素を出力し、
% Ir と Jc にスパース行データと列データを出力します。Jacobianがスカラ拡張
% の場合、ブーリアン needs_scalar_expansion を決定します。拡張は1つの
% 入力からであると仮定されます。出力数は、T の遅延数によって決定されます。


%   Copyright 1990-2002 The MathWorks, Inc.
