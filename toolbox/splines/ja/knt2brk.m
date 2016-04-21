% KNT2BRK   節点列からブレークポイントへ変換し、多重度を表示
%
%        [XI,M] = KNT2BRK(T)
%
% は、T の中の異なる要素の増加する順のリスト XI と、それらの多重度 
% M(i) := #{ j : T(j) = XI(i) }, i=1:length(XI) も出力します。
%
% たとえば、[xi,m] = knt2brk( [ 1 2 3 3 1 3] ) は、xi に対して [1 2 3] を
% 出力し、m に対して [2 1 3] を出力します。
%
% 参考 : BRK2KNT, KNT2MLT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc. 
