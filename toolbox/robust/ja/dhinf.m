% DHINF   離散時間H∞制御設計(双一次変換)
%
%     << 離散系4-ブロック最適H∞コントローラ(全ての解の方程式) >>
%       (Bilinear Transform, Safonov, Limebeer and Chiang, 1989 IJC)
%
%   [SS_CP,SS_CL,HINFO,TSS_K]=DHINF(TSS_P,SS_U,VERBOSE)は、Safonov,
%   Limebeer, Chiang(IJC, 1989)の"ループシフティング公式"と双一次補間を
%   使って、離散H∞コントローラF(z)とコントローラのパラメトリゼーション
%   K(z)を計算します。無限大ノルムが1以下の安定なU(z)を与えると、F(z)は
%   K(z)について、U(z)をフィードバックすることで構成されます。
%   要求される入力--
%      拡大プラントP(z) : TSS_P=MKSYS(A,B1,B2,C1,C2,D11,D12,D21,D22)
%   オプション入力--
%      安定なU(z)       : SS_U=MKSYS(AU,BU,CU,DU) (デフォルト: U=0)
%               VERBOSE :  1の場合、結果を表示します(デフォルト)
%                          0の場合、HINFは何も表示しません
%   出力データ: 
%       コントローラF(z)        :  SS_CP=MKSYS(ACP,BCP,CCP,DCP)
%       閉ループ伝達関数Ty1y1(z):  SS_CL=MKSYS(ACL,BCL,CCL,DCL)
%              hinfo = (hinflag,RHP_cl,lamps_max)
%       "hinflag"は、H∞の存在を示すASCIIのフラグです。
%       全ての解のコントローラのパラメトリゼーションK(z):
%                     TSS_K=MKSYS(A,BK1,BK2,CK1,CK2,DK11,DK12,DK21,DK22)
% 
%   このファイルは、あらかじめ入力引数(A,B1,B2,C1,C2,D11,D12,D21,D22)を
%   メインワークスペースで定義しておき、DHINFをタイプすることによって、
%   スクリプトファイルをしても使うことができます。このとき、
%   変数(ss_cp,ss_cl,acp,bcp,ccp,dcp,acl,bcl,ccl,dcl,hinfo)は、
%   メインワークスペースに出力されます。



% Copyright 1988-2002 The MathWorks, Inc. 
