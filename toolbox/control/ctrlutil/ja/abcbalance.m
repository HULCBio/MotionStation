% ABCBALANCE は、状態空間モデルの平衡化を行います。
%
% [A,B,C,E,T] = ABCBALANCE(A,B,C,E,CONDT) は、BALANCE を使って、[T*A/T,
% T*B;C/T,0] が近似的に等しい行と列のノルムをもつような対角相似変換 T を
% 計算します。CONDT は、T の条件数を上界として設定します。
%
% SSBAL でコールされる低水準ユーテリティです。

% $Revision: 1.6 $ $Date: 2002/04/10 06:39:24 $
%   Copyright 1986-2002 The MathWorks, Inc. 
% $Revision: 1.6 $ $Date: 2002/04/10 06:39:24 $
%   Copyright 1986-2002 The MathWorks, Inc. 
