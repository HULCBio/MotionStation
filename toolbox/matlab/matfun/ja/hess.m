% HESS   Hessenberg型
% 
% H = HESS(A) は、行列AのHessenberg型行列です。
% 行列のHessenberg型は、主対角の1つ下側の対角成分より下の部分がゼロで、
% A と同じ固有値をもちます。行列が対称またはエルミートの場合は、行列は三重
% 対角です。
%
% [P,H] = HESS(A) は、A = P*H*P' かつ P'*P = EYE(SIZE(P)) であるようなユニ
% タリ行列 P とHessenberg行列 H を出力します。
%
% [AA,BB,Q,Z] = HESS(A,B) は、正方行列 A と B に対して、つぎを満たす、
% 上 Hessenberg 行列 AA, 上三角行列 BB, ユニタリ行列 Q および Z を生成します。
%      Q*A*Z = AA,  Q*B*Z = BB.

%   Copyright 1984-2002 The MathWorks, Inc. 

