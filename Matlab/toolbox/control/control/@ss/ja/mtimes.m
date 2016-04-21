% MTIMES   LTIモデルの乗算
%
% SYS = MTIMES(SYS1,SYS2)は、SYS = SYS1 * SYS2 を計算します。2つの
% LTIモデルの乗算は、下記に示す直列結合と等価です。
%
%     u ----> SYS2 ----> SYS1 ----> y 
%
% SYS1 と SYS2 が、それぞれLTIモデルの配列のとき、これらの乗算は、
% モデルの数と同数のLTI配列 SYS になります。ここで、k 番目のモデルは、
% 
%   SYS(:,:,k) = SYS1(:,:,k) * SYS2(:,:,k) 
% 
% です。
%
% 参考 : SERIES, MLDIVIDE, MRDIVIDE, INV, LTIMODELS.


%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
