% MUSYN 自動的なμ解析の実行
%
% [SS_CP,MU,LOGD,SS_D,GAM] = MUSYN(TSS_,W)、または、
% [SS_CP,MU,LOGD,SS_D,GAM] = MUSYN(TSS_,W,GAMIND,AUX,LOGD0,N,BLKSZ,FLAG)
% は、hinfoptとfitd,ssvを使って、μ解析D-Fイタレーションを自動的実行しま
% す。
% 
% 入力: TSS_ = mksys(A,B1,B2,...,D21,D22)  --- プラント
%       W    = fitdでカーブフィッティングするために利用される周波数
% 出力:
%       SS_CP = mksys(ACP,BCP,CCP,DCP) --- μ解析コントローラ
%       LOGD     --- psv.mから出力される閉ループ対角スケーリングの
%                    対数マグニチュード

% Copyright 1988-2002 The MathWorks, Inc. 
