% ACCELBUILD は、モデルに対するAccekerator mex-ファイルを作成します。
% 高速化するシミュレーションをスタートする部分で、自動的に行なわれますが、
% この関数を使うことにより、プログラム的に行なうこともできます。
%
% ACCELBUILD('MODELNAME',OPTIONS)
%   OPTIONS: OPT_OPTS=-g
%   作成した mex-ファイルに最適化を行わず、デバッグシンボルを加えます。
%      accelbuild('f14','OPT_OPTS=-g');
%



%   Copyright 1994-2001 The MathWorks, Inc.
