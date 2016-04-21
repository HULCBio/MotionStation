% SSINV は、状態空間システムの逆システム計算を行ないます。
%
% [SS_I] = SSINV(SS_)、または、
%                                                      -1         -1      
% [AI,BI,CI,DI] = SSINV(A,B,C,D) は、状態空間式 AI=A-B D  C, BI=B D  , 
%      -1       -1
% CI=-D  C, DI=D を使って、逆システム
%                       -1
%         GI(s) = [G(s)]
% 
% を計算します。

% Copyright 1988-2002 The MathWorks, Inc. 
