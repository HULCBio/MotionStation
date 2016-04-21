% IDMODRED   モデルの低次元化
%   Control Systems Toolbox が必要です。
%   MRED = IDMODRED(M,ORDER)
%
%   M     : IDMODEL(IDPOLY, IDARX, IDPOLY, IDGREY) として定義されたオリ
%           ジナルモデル
%   ORDER : モデルを低次元化するときの希望する次数
%      ORDER=[](デフォルト)の場合、プロットが表示され、次数の選択を要求
%           してきます。
%   MRED = IDMODRED(M,ORDER,'DisturbanceModel','None') を使って、出力誤
%          差モデル(K = 0) が作成され、一方、ノイズモデルも低次元化され
%          ます。
%   MRED  : 低次元化されたモデルで、IDSS モデルとして表現
%
% ルーチンは、Control System Toolbox の関数 balreal と modred をベースに
% しています。
%
% 参考： BALREAL, MODRED, IDMODEL.

%   L. Ljung 10-10-93


%   Copyright 1986-2001 The MathWorks, Inc.
