% TRANSPOSE   周波数応答データオブジェクトの転置
%
% TSYS = TRANSPOSE(SYS) は、TSYS = SYS.' で呼び出されます。
%
% SYS と TSYS の応答データは、つぎのように対応します。 
% 
% 各周波数点で
%    TSYS.ResponseData = SYS.ResponseData.'
%
% SYS を伝達関数 H(s) または H(z) とすると、このとき、TSYS は、伝達関数 
% H(s).' となります(離散時間では、H(z).' に対応)。
%
% 参考 : CTRANSPOSE, FRD, LTIMODELS.


%   Author(s): S. Almy
%   Copyright 1986-2002 The MathWorks, Inc. 
