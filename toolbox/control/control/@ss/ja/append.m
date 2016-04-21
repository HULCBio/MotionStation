% APPEND   入力および出力を付加し、LTIモデルをグループ化
%
% SYS = APPEND(SYS1,SYS2, ...) は、つぎの結合システムを作成します。
% 
%              [ SYS1  0       ]
%        SYS = [  0   SYS2     ]
%              [           .   ]
%              [             . ]
%
% APPENDは、LTIモデル SYS1, SYS2,... の入力および出力ベクトルを付加して、
% 拡大モデル SYS を作成します。
%
% SYS1,SYS2,... が、LTIモデルの配列である場合、APPEND は同じサイズの 
% LTI配列モデル SYS を出力します。ここで、
% 
%   SYS(:,:,k) = APPEND(SYS1(:,:,k),SYS2(:,:,k),...)
% 
% です。
%
% 参考 : SERIES, PARALLEL, FEEDBACK, LTIMODELS.


%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
