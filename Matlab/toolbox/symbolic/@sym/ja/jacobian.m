% JACOBIAN   Jacobian 行列
% JACOBIAN(f, v) は、ベクトル v について、スカラ、または、ベクトル f の 
% Jacobian を計算します。結果の(i, j)要素は、df(i)/dv(j) です。f がスカ
% ラのとき、f のJacobian は 、f の勾配です。また、これは、DIFF(f, v) と
% 同じですが、スカラ v を使うことができます。
%
% 例題:
% 
%       jacobian([x*y*z; y; x+z],[x y z])
%       jacobian(u*exp(v),[u;v])
%
% 参考： DIFF.



%   Copyright 1993-2002 The MathWorks, Inc.
