% a=jwreg(a,b2,c1,d12,knobjw)
%
% 関数GOPTRICとPLANTREGで利用。
%
% マシンイプシロンを利用しての正則化A -> A + eps*Iにより、つぎのシステム
% の虚軸上の零点を削除します。
%
%                    [ A - s I    B2 ]
%           P12(s) = [               ]
%                    [ C1        D12 ]
%
% P21(s)を正則化するために、つぎのように実行されます。
% 
%      a=jwreg(a',c2',b1',d21',knobjw)'
%
% KNOBJWは[0,1]の値で、eps-正則化の割合をコントロールします。
% (epsの値がKNOBJWで増加します)
%
% 参考：   HINFRIC.

% Copyright 1995-2001 The MathWorks, Inc. 
