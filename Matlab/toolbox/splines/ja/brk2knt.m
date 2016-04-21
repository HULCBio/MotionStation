% BRK2KNT   多重度をもつブレークポイント列から節点列を作成
%
% T = BRK2KNT(BREAKS,MULTS) は、すべてのiに対して、BREAKS(i) が MULTS(i)回
% 繰り返された形の節点列 T を出力します。BREAKS が厳密な意味で増加する
% 場合、T は、各 BREAKS(i) が正確に MULTS(i)回発生する節点列です。
%
% MULTS が定数であるべき場合、その定数値のみが与えられる必要があります。 
%
% [T,INDEX] = BRK2KNT(BREAKS,MULTS) は、INDEX = [1 find(diff(T)>0)-1] も
% 出力します。すべての多重度が正ならば、すべての j に対して INDEX(j) は
% T の中で BREAKS(j) が現れる最初の位置です。
%
% 例題:
%    t = brk2knt(1:2,3)
% は、t = [1 1 1 2 2 2] を与えます。一方、
%
%    t = [1 1 2 2 2 3 4 5 5];  [xi,m] = knt2brk(t);  tt = brk2knt(xi,m);
%
% では、xi は [1 2 3 4 5]、m は [2 3 1 1 2]、tt は t を与えます。
%
% 参考 : KNT2BRK, KNT2MLT, AUGKNT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc. 
