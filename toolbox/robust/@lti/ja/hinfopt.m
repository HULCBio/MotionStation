% HINFOPT γイタレーションによるH∞コントローラシンセシス
%
% [GAM_OPT,SS_CP,SS_CL] = HINFOPT(TSS_,GAMIND,AUX)、または、
% [GAM_OPT,ACP,BCP,CCP,DCP,ACL,BCL,CCL,DCL] ....
%                 = HINFOPT(A,B1,..,GAMIND,AUX) は、与えられたシステム
% Tcl:(TSS_)に対して、ループシフティングにより改善された2つのリカッチ方
% 程式により最適H∞制御則を求めるために、H∞γイタレーションを実行します。
% 
% "Gam_opt"は、つぎの定式に対して最適な"γ"です。
%
%                   || gamma * Tcl(gamind,:)   ||
%                   ||                         ||     <= 1
%                   ||         Tcl(otherind,:) || inf
% ここで、
%       Tcl(gamind,:) は、"γ"により重み付けされた行を含み、
%       Tcl(otherind,:) は、Tclのその他の行を含みます。
% 
%   入力           :  Tcl: TSS_ = mksys(A,B1,B2,C1,C2,D11,D12,D21,D22);
%   オプション入力 :
%           gamind : γでスケーリングされた出力のインデックス
%                    (デフォルト: 全ての出力チャンネル)
%           aux    : [tol, maxgam, mingam] (デフォルト: [0.01 1 0])
%                     tol    : イタレーションを終了するための許容誤差
%                     maxgam : 最大の"gam_opt"のための初期推定値
%                     mingam : 最小の"gam_opt"のための初期推定値
%   出力: gam_opt (最適なγ)
%         H∞最適コントローラ:        ss_cp = mksys(acp,bcp,ccp,dcp)
%         γで重み付けされた閉ループ: ss_cl = mksys(acl,bcl,ccl,dcl)



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
