% TWOBVP 厳密な意味で2つの解をもつ BVP を解きます。
% 
% TWOBVP は、BVP4C を使って、
% 
%      y'' + |y| = 0
% 
% の2つの解を計算します。ここで、つぎの境界条件を満足します。
% 
%      y(0) = 0,  y(4) = -2
% 
% この例題は、初期推定値により、いかに異なる解を導くかを示しています。
% 
%   
% 参考： TWOODE, TWOBC, BVPINIT, BVPSET, BVPGET, BVP4C, DEVAL, @.


%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 01:49:35 $

