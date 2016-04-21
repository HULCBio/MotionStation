% HINFKGJD は、H∞制御系シンセシス(Glover/Doyle 手法)
%
%     << 4-block L-inf optimal Controller (all solution formulae) >>
%               (derived by K. Glover & J. Doyle, 1988)
%
% HINFKGJD は、Glover-Doyle の方法による、2つのリカッチ方程式の全ての解を
% 用いて、H∞最適コントローラを計算する、スクリプトファイルです。
% 特殊解コントローラ F(s) は、デフォルトですが、あらかじめワークスペースに、
% 以下のように指定されている伝達関数を用いて、別の解を作成することもできま
% す。
% 
%   U(s) := (AU, BU, CU, DU)
% 
% ここで、U(s) は、自由で安定な項で、全ての安定化解のパラメータライズに制
% 約を設けます。
% 
% 　　　入力データ (上記の例では、必ず必要!!!)
%       拡大系 (A,B1,B2,C1,C2,D11,D12,D21,D22)
%         安定な制約項　U(s) := (AU,BU,CU,DU) (オプション)
% 　　　出力データ：H∞コントローラ F(s) := (acp,bcp,ccp,dcp)
%         閉ループ伝達関数 Ty1u1 := (acl,bcl,ccl,dcl)
% 

% Copyright 1988-2002 The MathWorks, Inc. 
