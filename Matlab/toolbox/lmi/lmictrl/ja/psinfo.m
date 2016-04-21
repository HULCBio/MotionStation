% PSINFOは、PSYSで設定されたポリトピックシステム、または、パラメータ依存
% システムPSに関する種々の情報を与えます。
%
% PSINFO(PS)
% システムの特性を表示します。
%
% [TYP,K,NS,NI,NO] = PSINFO(PS)
% システムのタイプ(ポリトピックシステムに対して'pol'、アフィンパラメータ
% 依存システムに対して'aff')、この定義に関連するSYSTEM行列の数K、状態、
% 入力、出力の数NS, NI, NOを出力します。
%
% PV = PSINFO(PS,'par')
% パラメータベクトルの記述を出力します(パラメータ依存システムのみ)。
%
% SK = PSINFO(PS,'sys',K)
% PSの定義に関連するK番目のSYSTEM行列Skを出力します。
%
% SYS = PSINFO(PS,'eval',P) 
%    ポリトピック、または、パラメータ依存の状態空間モデルを示します。結
%    果は、つぎのように与えられる SYSTEM 行列 SYS です。
%    PS がポリトピックで、P = (p1,...,pk), pj >= 0 がポリトピック座標系
%    の場合、
%
%               p1*S1 + ... + pk*Sk
%      * SYS =  -------------------    
%                 p1 + ... + pk
%
%    PS がアフィンで、P がパラメータベクトルの特別な値の場合、
%
%      * SYS = S0 + p1*S1 + ... + pk*Sk   
%
% 参考：    PSYS, PVEC, LTISYS.



% Copyright 1995-2002 The MathWorks, Inc. 
