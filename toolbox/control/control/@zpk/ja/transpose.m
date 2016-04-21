% TRANSPOSE   零点-極-ゲインモデルを転置
%
% TSYS = TRANSPOSE(SYS) は、TSYS = SYS.' を表します。
%
% SYS と TSYS の極-零点-ゲインデータは、つぎのように関連付けられます。 
% 
%    TSYS.Z = (SYS.Z).'
%    TSYS.P = (SYS.P).'
%    TSYS.K = (SYS.K).'
%
% SYS が伝達関数 H(s) または H(z) で表現されるとき、TSYS は、伝達関数 
% H(s).' で、表されます(離散時間では、H(z).')。
%
% 参考 : CTRANSPOSE, ZPK, LTIMODELS.


%   Author(s): P.Gahinet, 4-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
