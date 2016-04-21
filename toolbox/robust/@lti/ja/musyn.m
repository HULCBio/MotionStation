% MUSYN 自動的なμシンセシスの実行
%
% [SS_CP,MU,LOGD,SS_D,GAM] = MUSYN(TSS_,W)、または、
% [SS_CP,MU,LOGD,SS_D,GAM] = MUSYN(TSS_,W,GAMIND,AUX,LOGD0,N,BLKSZ,FLAG)
% は、hinfoptとfitd,ssvを使って、μシンセシス D-Fイタレーションを自動的実
% 行します。
% 
% 入力: TSS_ = mksys(A,B1,B2,...,D21,D22)  --- プラント
%       W    = fitdでカーブフィッティングするために利用される周波数
% 出力:
%       SS_CP = mksys(ACP,BCP,CCP,DCP) --- μシンセシスコントローラ
%       LOGD     --- psv.mから出力される閉ループ対角スケーリングの
%                    対数マグニチュード



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
