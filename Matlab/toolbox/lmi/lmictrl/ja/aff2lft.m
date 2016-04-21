%  [sys,delta] = aff2lft(affsys)
%
% つぎの方程式で表現されるアフィンパラメータ依存システムAFFSYSを入力しま
% す。
%
%             E(p) dx/dt  =  A(p) x  +  B(p) u
%                      y  =  C(p) x  +  D(p) u
%
% AFF2LFTは、つぎの型の等価な線形分数表現を出力します。
%
%                    ___________
%                    |         |
%               |----|  DELTA  |<---|
%               |    |_________|    |
%               |                   |
%               |    ___________    |
%               |--->|         |----|
%                    |   SYS   |
%           u  ----->|_________|----->  y
%
% ここで、
% * ノミナルなシステムSYSは、パラメータp1, ..., pKの平均値に対応します。
% * DELTAは、つぎの型のブロック対角な不確かさ構造です。
%            DELTA =  blockdiag (d1*I , ... , dK*I)
%      
%           | dj |  <=  (pj_max - pj_min)/2
%
%
% 参考：    PSYS, PVEC, UBLOCK, PSINFO, PVINFO, UINFO.



%   Copyright 1995-2002 The MathWorks, Inc. 
