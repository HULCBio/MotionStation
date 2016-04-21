% SEQSRCH は、ANFIS モデリング SEQSRCH の中の入力部に対する連続的で前向
% きな探索
%
% SEQSRCH は、ANFIS モデリング用の入力候補の集合の1から4までの入力を選択
% しながら連続的な前向き探索を行います。
% 
% SEQSRCH は、M 個の候補から N 個の入力を選択したい場合、(2*M-N+1)*N/2 
% 回の ANFIS モデリングプロセスを実行します。
% 
%	使用法:
%	[INPUT_INDEX, ELAPSED_TIME] = ...
%	SEQSRCH(IN_N, TRN_DATA, CHK_DATA, INPUT_NAME, MF_N, EPOCH_N)
%
%	INPUT_INDEX  : SEQSRCH に依り選択される入力群のインデックス
%	ELAPSED_TIME : 入力部の中での経過時間
%	IN_N         : 入力候補から選択される入力数
%		       (これは、1から4の間の整数とします)
%	TRN_DATA     : オリジナルの訓練データ
%	CHK_DATA     : オリジナルのチェックデータ
%	INPUT_NAME   : すべての入力候補に対する入力名
%		       (オプションで、デフォルトは、'in1', 'in2', 'in3' 
%                      等です)
%	MF_N         : 各入力用のメンバーシップ関数の番号
%		       (オプションで、デフォルトは 2です)
%	EPOCH_N      : ANFIS用の訓練回数の番号
%		      (オプションで、デフォルトは1です)
% 自動車の燃費(1ガロンでのマイル数)予測用の選択入力のセルフデモでは、
% EXHSRCH と入力
%
% 参考  SEQSRCH.
		
%45 %%%%%%%%%%%%%%%

