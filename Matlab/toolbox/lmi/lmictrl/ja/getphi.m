% 関数KCENで利用
%
% 非正則Hinfコントローラに対して、修正項PhiBやPhiCを計算。Phiは次の条件
% を満足しなければいけません。
% 
%     *  DR + P' Phi  + Phi' P < 0
%     *  (A+B*Phi,E) が安定
%
% 安定余裕とPhiのノルムとのトレードオフが、-alpha*Pの陽解に基づいて最適
% 化されます。最適なトレードオフは、BASICLMIの結果と比較されます。

% Copyright 1995-2001 The MathWorks, Inc. 
