% [a,b2]=ucreg(a,b2,c1,d12,knobjw)
%
% 関数DGOPTRICで利用。
%
% eps-正則化 [A,B2] -> (1+eps)*[A,B2]により、つぎのシステムの単位円上の
% 零点を除去します。
%
%                    [ A - z I    B2 ]
%           P12(z) = [               ]
%                    [   C1      D12 ]
%
% P21(z)を正則化するために、つぎのように実行します。
% 
%      a=jwreg(a',c2',b1',d21',knobjw)'
%
% KNOBJWは[0,1]の値で、eps-正則化の割合をコントロールします(KNOBJWでeps
% を増加します)。
%
% 参考：    DHINFRIC.
% 

% Copyright 1995-2001 The MathWorks, Inc. 
