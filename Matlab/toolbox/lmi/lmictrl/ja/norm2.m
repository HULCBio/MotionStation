% nh2 = norm2(sys)
%
% 安定で厳密にプロパなLTIシステムのH2ノルムを計算します。
%                               -1
%                 SYS = C (sE-A)  B
%
% このノルムは、つぎの式で与えられます。
%                  ______________
%                 /
%                V  Trace(C*P*C')
%
% ここで、PはLyapunov方程式 A*P+P*A'+B*B' = 0を解きます。
%
% 参考：    LTISYS.



% Copyright 1995-2002 The MathWorks, Inc. 
