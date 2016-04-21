% CTRANSPOSE   周波数応答データオブジェクトの共役転置
%
% TSYS = CTRANSPOSE(SYS) は、TSYS = SYS' を行います。
%
% SYS を連続時間伝達関数 H(s) とすると、TSYS は、その共役転置 H(-s).' 
% となります。離散時間の場合、SYS を H(z) とすると TSYS は、H(1/z).' に
% なります。 
%
% 参考 : TRANSPOSE, FRD, LTIMODELS.


%   Author(s): A. Potvin, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
