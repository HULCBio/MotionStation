% UNWRAP   位相角の連続性
% 
% UNWRAP(P)は、変化の絶対値がpiより大きいとき、2*piの補数に変更して、位
% 相角Pを連続にします。この関数はPの最初に1でない次元で行います。Pは、ス
% カラ、ベクトル、行列、N次元配列のいずれかです。
%
% UNWRAP(P,TOL)は、デフォルト値piの代わりに、ジャンプトレランスTOLを使い
% ます。
%
% UNWRAP(P,[],DIM)は、デフォルトのトレランスを使って、DIMで指定される次
% 元で演算します。UNWRAP(P,TOL,DIM)は、ジャンプトレランスTOLを使います。
%
% 参考 ANGLE, ABS.

%   Original: J.N. Little, 4-1-87.
%   Revised:  C R. Denham, 4-29-90. 
%             D.L. Chen, 3-22-95.
%   Modified: P. Gahinet, 7-99
%   Copyright 1984-2004 The MathWorks, Inc. 
