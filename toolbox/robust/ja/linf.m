% LINF は、連続系の L∞制御系シンセシスを行います。
%
% ----------------------------------------------------------------
%       L-inf optimization for Multivariable Feedback Systems
%
%       LINF (MATLAB) Ver. 2.0 -- R. Y. Chiang & M. G. Safonov
% ----------------------------------------------------------------
% LINF は、Youla パラメトリザーションと最適 Hankel 近似を使って、無限大ノ
% ルム制御問題を解きます。
%
%      入力データ：拡大プラント
%            (A,B1,B2,C1,C2,D11,D12,D21,D22) (大文字であることに注意!!)
%
%      出力データ：コントローラ F(s) := (acp,bcp,ccp,dcp)
%             CLTF Ty1u1 := (acl,bcl,ccl,dcl)
%

% Copyright 1988-2002 The MathWorks, Inc. 
