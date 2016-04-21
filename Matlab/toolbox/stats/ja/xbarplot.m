% XBARPLOT   平均値をモニタする X-bar 図
%
% XBARPLOT(DATA,CONF,SPECS,SIGMAEST) は、DATA のグループ化された応答の 
% X-bar 図を作成します。DATA の行は、設定した時刻で実行された観測を含んで
% います。行は、時間順に並べたものです。
%
% CONF (optional) は、プロットする信頼区間の上限と下限を示すものです。
% CONF のデフォルト値は0.9973です。この値は、プロットされる点の99.73% が、
% プロセスが管理下にある場合に、この管理区間に入ることを意味しています。
%
% SPECS (optional) は、2要素からなるベクトルで、応答の下限と上限を設定
% するものです。
%
% SIGMAEST (optional) は、SBARPLOT がどのようにシグマを推定するかを示す
% ものです。利用できる値は、サブグループの標準偏差の平均を使う 'std'
% (デフォルト)、平均のサブグループレンジを使う 'range'、利用する分散の
% 平方根を使う 'variance' です。
%
% OUTLIERS = XBARPLOT(DATA,CONF,SPECS,SIGMAEST) は、DATA の平均が管理外
% になる行のインデックスを示すベクトルを出力します。
%
% [OUTLIERS, H] = XBARPLOT(DATA,CONF,SPECS,SIGMAEST) は、プロットした
% ラインのハンドル番号 H を出力します。


%   B.A. Jones 9/30/94
%   Modified 4/5/99 by Tom Lane
%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:16:31 $
