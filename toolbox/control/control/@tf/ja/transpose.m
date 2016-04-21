% TRANSPOSE   伝達関数モデルを転置
%
% TSYS = TRANSPOSE(SYS) は、TSYS = SYS.' を表します。
%
% SYS と TSYS の分子多項式と分母多項式は、つぎの関係になります。
% 
%    TSYS.NUM = SYS.NUM.'
%    TSYS.DEN = SYS.DEN.'
%
% SYS が、伝達関数 H(s) または H(z) を表すとき、TSYS は、伝達関数 H(s).'
% を表します(離散時間では、H(z).')。
%
% 参考 : CTRANSPOSE, TF, LTIMODELS.


%   Author(s): P.Gahinet, 4-1-96
%   Copyright 1986-2002 The MathWorks, Inc. 
