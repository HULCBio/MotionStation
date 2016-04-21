% H2LQG 連続時間H2制御シンセシス
%
% [SS_CP,SS_CL]=H2LQG(TSS_,ARETYPE) は、閉ループ伝達関数Ty1u1(s)のH2ノル
% ムが最小となるように適切なループ整形重み関数で"拡大された"プラントP(s)
% に対して、H2最適コントローラを計算します。
%
% 要求される入力データ:
%  拡大プラント P(s): TSS_ = MKSYS(A,B1,B2,C1,C2,D11,D12,D21,D22,'tss')
%
% オプション入力:
%  リカッチソルバ: aretype = 'eigen'、または、'Schur' 
%                  (デフォルトは、'eigen')
%
% 出力データ:
%  コントローラ F(s)               :   SS_CP = MKSYS(acp,bcp,ccp,dcp)
%  Ty1u1(s)の閉ループ伝達関数(CLTF):   SS_CL = MKSYS(acl,bcl,ccl,dcl)
%
% 警告:  
% D11行列が0であるか、または問題が悪条件であるかに注意してください。
% D11が0でない場合でも、H2LQGは、D11が0であることを仮定してコントローラ
% を求めます。



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
