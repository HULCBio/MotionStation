% ANFIS   菅野タイプFISの適応ニューロファジー訓練
%
% ANFISは菅野タイプファジー推論システム(FIS)の単出力のメンバシップ関数
% パラメータの同定に、ハイブリッドな学習アルゴリズムを利用します。
% 与えられた入出力データに基づき、最小二乗法とバックプロパゲーション最急
% 降下法を組み合せた手法でモデルのFISメンバシップ関数のパラメータ訓練を
% 行います。
% 
% [FIS,ERROR] = ANFIS(TRNDATA) はTRNDATAにストアされた入出力学習データを
% 用いてFISパラメータをチューニングします。N入力のFISの場合、TRNDATAは
% N+1列の行列で、最初のN列にFIS入力、最後の列に出力データを持ちます。
% ERRORは各エポックにおける訓練誤差（FIS出力と訓練データの出力との差）の
% 平均二乗根の配列です。ANFISはANFIS訓練の開始点に利用されるデフォルト
% FIS作成にGENFIS1を用います。
%
% [FIS,ERROR] = ANFIS(TRNDATA,INITFIS) はFIS構造体を利用します。INITFISは
% ANFIS訓練の開始点です。
%
% [FIS,ERROR,STEPSIZE] = ANFIS(TRNDATA,INITFIS,TRNOPT,DISPOPT,[],OPTMETHOD)
% は訓練オプションの指定のためにTRNOPTベクトルを用います。
%       TRNOPT(1): 訓練エポック回数                (デフォルト: 10)
%       TRNOPT(2): 訓練誤差の目標                  (デフォルト: 0)
%       TRNOPT(3): 初期ステップサイズ              (デフォルト: 0.01)
%       TRNOPT(4): ステップサイズの減少率          (デフォルト: 0.9)
%       TRNOPT(5): ステップサイズの増加率          (デフォルト: 1.1)
% 学習プロセスは、指定されたエポック数、または、訓練誤差の目標値に到達した
% 地点で終了します。STEPSIZEはステップサイズの配列です。ステップサイズの
% 増減は学習オプションで指定された増加、または減少ステップサイズ率を乗じる
% ことで決まります。デフォルトの値を利用するにはNaNを指定します。
%
% DISPOPTベクトルは学習中の表示オプションの指定に利用します。1は情報の
% 表示を、0は非表示を意味します:
%
%    DISPOPT(1)   :一般的なANFIS情報              (デフォルト: 1)
%    DISPOPT(2)   :エラー                         (デフォルト: 1)
%    DISPOPT(3)   :各パラメータの更新時のステップサイズ(デフォルト: 1)
%    DISPOPT(4)   :最終結果                       (デフォルト: 1)
%
% OPTMETHODは学習に利用する最適化手法を指定します。1はデフォルトのハイブリッド
% 法を選択します。これは最小二乗推定とバックプロパゲーションの結合した手法です。
% 0はバックプロパゲーション法を利用します。
%
% [FIS,ERROR,STEPSIZE,CHKFIS,CHKERROR] = ...
% ANFIS(TRNDATA,INITFIS,TRNOPT,DISPOPT,CHKDATA) はチェック（評価）データ
% CHKDATAを学習データセットのオーバーフィッディングのために指定します。CHKDATAは
% TRNDATAと同じフォーマットです。オーバーフィッディングは、学習エラーが増加している
% 間に、チェッキングエラー(CHKFISからの出力とチェックデータとの差）が増加している
% 現象を検知できます。CHKFISはチェッキングデータエラーが最小になったときのFISの
% スナップショットです。CHKERRORは書くエポックのチェッキングデータエラーの平均
% 二乗和根の配列です。
% 
%   例
%       x = (0:0.1:10)';
%       y = sin(2*x)./exp(x/5);
%       epoch_n = 20;
%       in_fis  = genfis1([x y],5,'gbellmf');
%       out_fis = anfis([x y],in_fis,epoch_n);
%       plot(x,y,x,evalfis(x,out_fis));
%       legend('Training Data','ANFIS Output');
%
% 参考 GENFIS1, ANFISEDIT.


%   Copyright 1994-2002 The MathWorks, Inc. 
