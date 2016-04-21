% C2D は、連続時間から離散時間への変換を実行します。
%
% MD = C2D(MC,T,METHOD)
%
% MC: IDMODEL オブジェクトとして与えられる連続時間モデル
%
% T : サンプリング間隔
% MD: 離散時間モデル、IDMODEL モデルオブジェクト
% METHOD: 'Zoh' (デフォルト) または 'Foh'
%     入力がゼロ次ホールド(区分的定数)や一次ホールド(区分的線形)である
%     ことの仮定に対応します。
%      
% IDPOLY モデルは、IDPOLYモデルとして出力されます。
% IDSS モデルは、IDSSモデルとして出力されますが、'Structured' パラメト
%      リゼーションが 'Free' に変更されます。
% IDGREY モデルは、'CDmfile' == 'cd' の場合 IDGREY モデルとして出力され、
%        その他の場合、IDSS モデルとして出力されます。
%   
% MC の InputDelay は、MD に継承されます。
% T の定数倍でない InputDelays を取り扱うためには、Control System Toolbox
% が必要です。
%
% IDPOLY モデルに対して、MC の共分散行列 P は、数値微分を用いて変換
% されます。微分に対して用いられるステップサイズは、M-ファイル NUDERST
% で与えられます。IDSS、IDARX、および IDGREY モデルに対して、入出力特性
% についての共分散情報が含まれていますが、共分散行列は、変換されません。
%
% (ある程度の時間の)共分散情報の変換を防ぐには、
%    C2D(MC,T,Method,'CovarianceMatrix','None') 
% を使用します。(任意の略語を使用します)(最初に SET(MC,'Cov','No') を
% 行っても同じ効果が得られます)
%
% Control System Toolboxがインストールされている場合、つぎのように実行
% します。
%    MD = C2D(MD,T,METHOD)
% ここで、METHOD は、'tustin', 'prewarp', 'matched' のいずれかであり、
% 変換は、対応する手法で実行されます。HELP SS/C2D を参照してください。
% その後、共分散情報は変換されません。
%
%   参考:  IDMODEL/D2C


%   L. Ljung 10-2-90, 94-08-27
%   Copyright 1986-2001 The MathWorks, Inc.
