% READTREE　　 Figure からウェーブレットパケット分解を読み取ります。
% [T,D] = READTREE(F) は、Figure F のウェーブレットパケット分解を読みとります。
% T はツリー構造、D は T に関連するデータ構造です。
%
% 例題:
%   x = sin(8*pi*[0:0.005:1]);
%   [t,d] = wpdec(x,3,'db2');
%   fig   = drawtree(t,d);
%   %--------------------------------
%   % ノードの分割、マージに GUI を活用
%   %--------------------------------
%   [t,d] = readtree(fig);
%
% 参考： DRAWTREE.



%   Copyright 1995-2002 The MathWorks, Inc.
