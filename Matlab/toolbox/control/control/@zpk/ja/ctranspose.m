% CTRANSPOSE   零点-極-ゲインモデルの共役転置
%
%
% TSYS = CTRANSPOSE(SYS) は、TSYS = SYS' を行います。
%
% SYS を連続時間伝達関数 H(s) とすると、TSYS は、その共役転置 H(-s).'となりま
% す。 .離散時間の場合、SYS を H(z) とすると TSYS は、H(1/z).' になります。
%
% 参考 : TRANSPOSE, ZPK, LTIMODELS.


% Copyright 1986-2002 The MathWorks, Inc.
