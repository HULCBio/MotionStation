% AVEKNT   節点の平均
%
% AVEKNT(T,K) は、連続するK-1個の節点の平均を出力します。すなわち、
% S_{K,T} で補間するとき、よい補間点として推奨される
%
%       TSTAR(i) = ( T_{i+1} + ... + T_{i+K-1} ) / (K-1)
%
% の点を選択します。
%
% たとえば、k と増加する列 breaks が与えられているとき、
%
%   t = augknt(breaks,k); x = aveknt(t,K);
%   sp = spapi( t , x, sin(x) );
%
% は、区間 [breaks(1) .. breaks(end)] 上の正弦関数にスプライン補間を
% 与えます。
%
% 参考 : SPAPIDEM, OPTKNT, APTKNT, CHBPNT.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
