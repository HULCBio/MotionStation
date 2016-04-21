%     << 4ブロック最適H∞コントローラ (全ての解公式) >>
%               (Safonov, Limebeer and Chiang, 1989 IJC)
%
% [SS_CP,SS_CL,HINFO,TSS_K]=HINF(TSS_P,SS_U,VERBOSE) は、
%    "ループシフト公式"を使って、H∞コントローラF(S)とコントローラのパラ
%    メトリゼーションK(S)を計算します。|| U ||_inf <=1 となる安定なU(s)
%    を与えると、F(S)はK(S)に対してU(S)をフィードバック結合し構成されま
%    す。
%
% 要求される入力 --
%   拡大プラント P(s): TSS_P=MKSYS(A,B1,B2,C1,C2,D11,D12,D21,D22)
%
% オプション入力 --
%   安定な縮小 U(s): SS_U=MKSYS(AU,BU,CU,DU) (デフォルト: U=0)
%           VERBOSE:  1の場合、冗長な結果の表示 (デフォルト),
%                     0の場合、HINF結果の非表示
%
% 出力データ: コントローラ F(s):        SS_CP=MKSYS(ACP,BCP,CCP,DCP)
%             閉ループ Ty1u1(s):        SS_CL=MKSYS(ACL,BCL,CCL,DCL)
%             hinfo = (hinflag,RHP_cl,lamps_max) 
%                     ("hinflag":存在性のフラグ)
%             全ての解となるコントローラのパラメトリゼーション K(s):
%                    TSS_K=MKSYS(A,BK1,BK2,CK1,CK2,DK11,DK12,DK21,DK2



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
