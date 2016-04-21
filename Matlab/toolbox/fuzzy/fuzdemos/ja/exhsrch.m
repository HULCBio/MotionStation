% EXHSRCH は、ANFIS モデリングの中での入力選択に関しての徹底した探索を行
% います。
% 
% EXHSRCH は、ANFIS モデリング用の入力候補群の中の1から4入力までの徹底し
% た探索を行います。
% 
% EXHSRCH は、M 個の候補の中から N 個の入力を選択する場合、C(M,N) 個の 
% ANFIS モデリング処理を行います。そのため、M が適度に大きく、N が M の
% 約半分くらいの場合、かなりの時間を要します。
%
% 使用法:
% [INPUT_INDEX, ELAPSED_TIME] = ...
%      EXHSRCH(IN_N, TRN_DATA, CHK_DATA, INPUT_NAME, MF_N, EPOCH_N)
%
%	INPUT_INDEX  : EXHSRCH より選択される入力群のインデックス
%	ELAPSED_TIME : 入力選択中の経過時間
%	IN_N         : 入力候補から選択される入力数
%		       (これは、1から4の間の整数とします)
%	TRN_DATA     : オリジナルの訓練データ
%	CHK_DATA     : オリジナルのチェックデータ
%	INPUT_NAME   : すべての入力候補に対する入力名
%		       (オプションで、デフォルトは、'in1', 'in2', 'in3' 
%                      等です)
%	MF_N         : 各入力用のメンバーシップ関数の番号
%		       (オプションで、デフォルトは 2です)
%	EPOCH_N      : ANFIS用の訓練回数
%		       (オプションで、デフォルトは1です)
%	
% 自動車の燃費(1ガロンでのマイル数)予測用の入力選択のセルフデモでは、EX-
% HSRCH と入力
%
% 参考  SEQSRCH.

