% function [T, invT, S, s]=ham2schr(a,b1,c1,epr);
%
% HAM2SCHRは、つぎのようなHamilton行列
%
%   H= [-a'     -c1*c1]
%      [b1*b1    a    ]
%
% を、ブロック対角がS = invT*H*Tであるように、左半平面、jw-軸、右半平面
% の3つのスペクトル部分空間に分解します。
%
% 参考: SDEQUIV, SDHFNORM, SDHFSYN

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:30:47 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
