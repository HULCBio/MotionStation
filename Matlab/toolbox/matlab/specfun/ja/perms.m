% PERMS   可能なすべての順列
% 
% PERMS(1:N) または PERMS(V) は、V が長さ N のベクトルのとき、各行が 
% N 個の要素のすべての可能な順列である N! 行 N 列の行列を作成します。
% 
% この関数は、Nが10未満の場合のみに、実用的なものです(N = 11 の場合、
% 出力は3ギガバイト以上になります)。
%
% 参考：NCHOOSEK, RANDPERM, PERMUTE.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:04:24 $
