% FNINT   関数の積分
%
% FNINT(F) は、F (の関数)の基本区間の左端点で0となる不定積分(の表示)を
% 出力します。
%
% FNINT(F,IFA) は、基本区間の左端点での不定積分の値を IFA として与えます。
%
% FNINT は、有理スプライン、またはst-型の関数に対しては機能しません。
%
% 例題:
%
%   fnder(fnint(f));
%
% は、(丸め誤差と、場合によっては、最後の節点の多重度を除いて) f と
% 同じです。
%
% 参考 : FNDER, FNDIR.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
