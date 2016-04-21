% HINFLIM 連続H∞コントローラのシンセシス(Limebeer/Kasenally 法)
%
%     << 4-block L-inf optimal Controller (all solution formulae) >>
%           (derived by Limebeer and Kasenally, Dec. 1987)
%
% HINFLIM は、Limebeer - Kasenallyis の方法による、2つのリカッチ方程式の全
% ての解を用いて、H∞最適コントローラを計算する、スクリプトファイルです。
% 特殊解コントローラ F(s) は、デフォルトですが、あらかじめワークスペースに、
% 以下のように指定されている伝達関数を用いて、別の解を生成することもできま
% す。
%                       U(s):= (AU,BU,CU,DU)
% ここで、U(s) は、自由で安定な項で、全ての安定化解のパラメタライズに制約
% を設けます。
%
%   入力データ(上記の例では必ず必要 !!!):
%              拡大系 (A,B1,B2,C1,C2,D11,D12,D21,D22)
%              安定な制約項 U(s):= (AU,BU,CU,DU) (optional)
%   出力データ：H∞コントローラ F(s):= (acp,bcp,ccp,dcp),
%                閉ループ伝達関数 Ty1u1:= (acl,bcl,ccl,dcl).
%

% Copyright 1988-2002 The MathWorks, Inc. 
