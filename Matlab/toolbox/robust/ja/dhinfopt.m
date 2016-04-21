% DHINFOPT は、γイタレーションによる離散 H ∞コントロールシンセシスを行
% います。
%
% [GAM_OPT,SS_CP,SS_CL] = DHINFOPT(TSS_,GAMIND,AUX)、または、
% [GAM_OPT,ACP,BCP,CCP,DCP,ACL,BCL,CCL,DCL] = HINFOPT(A,B1,..,GAMIND,AUX)
% 
% は、与えられたシステム Tcl:(TSS_) に対して、H ∞ γイタレーションを使
% って、改良されたループシフト2 Riccati 方程式を使って、最適 H ∞制御則
% を計算します。"Gam_opt" は、
%
%                   || gamma * Tcl(gamind,:)   ||
%                   ||                         ||     <= 1
%                   ||         Tcl(otherind,:) || inf
% 
%  に対する最適"γ"です。ここで、
%       Tcl(gamind,:) は、"γ"で重み付けされた行を含みます。
%       Tcl(otherind,:) は、Tcl の他の行を含みます。
%  入力：  Tcl: TSS_ = mksys(A,B1,B2,C1,C2,D11,D12,D21,D22);
%       オプション入力：
%           gamind: γでスケーリングされる出力のインデックス
%                   (デフォルト：すべての出力チャンネル)
%           aux   : [tol, maxgam, mingam] (デフォルト：[0.01 1 0])
%                   tol   : イタレーションを停止する基準になるトレランス
% 
%                   maxgam: 最大 "gam_opt" 用の初期推定
%                   mingam: 最小 "gam_opt" 用の初期推定
%  出力： gam_opt (最適γ)
%        H-∞最適コントローラ：  ss_cp = mksys(acp,bcp,ccp,dcp)
%        γ重み付き閉ループ  ： ss_cl = mksys(acl,bcl,ccl,dcl)

% Copyright 1988-2002 The MathWorks, Inc. 
