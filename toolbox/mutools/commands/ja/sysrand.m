% function out = sysrand(nstates,noutputs,ninputs,flg_stab)
%
% 指定した状態量、入力数と出力数をもつランダムなSYSTEM行列を作成します
% (正規分布する乱数を使います)。FLG_STAB = 1と設定すると、安定なランダム
% SYSTEM行列を作成します(デフォルトは、FLG_STAB = 0です)。
%
% 参考: CRAND, CRANDN, MINFO, PCK, PSS2SYS, SYS2PSS, RAND, RANDEL.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
