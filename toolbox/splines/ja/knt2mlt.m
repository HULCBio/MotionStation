% KNT2MLT   節点の多重度
%
% KNT2MLT(T) は、節点の多重度のベクトル M を出力します。正しくは、
%
% i=1:length(T) として、M(i) = # { j<i : T(j) = T(i) }
%
% となり、入力が並び替えられていない場合、T はここで最初に並び替えられ
% ます。
%
% [M,T] = KNT2MLT(T) は、並び替えた節点列も出力します。
%
% たとえば、[m,t] = knt2mlt([ 1 2 3 3 1 3]) は、m に対して [0 1 0 0 1 2] 
% を出力し、t に対して [1 1 2 3 3 3] を出力します。
%
% 参考 : KNT2BRK, BRK2KNT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc. 
