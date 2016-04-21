% DECONVBLIND Blind デコンボリューションアルゴリズムを使って、イメージの
% 回復
% [J,PSF] = DECONVBLIND(I,INITPSF) は、最尤法アルゴリズムを使って、イメー
% ジ I を分解し、明瞭化されたイメージ J と再構成された点像強度関数 PSF を
% 出力します。結果の PSF は、INITPSF と同じサイズの正の配列で、その和を1
% で正規化しています。PSF の再構成は、初期推定 INITPSF のサイズに強く影響
% され、その値にはあまり影響されません。
%   
% 再構成を改良するために、付加的なパラメータを使うことができます(中間のパ
% ラメータが未知の場合、[]を使ってください)。
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT)
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT,DAMPAR)
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT,DAMPAR,WEIGHT)
%   [J,PSF] = DECONVBLIND(I,INITPSF,NUMIT,DAMPAR,WEIGHT,READOUT).
%
% PSF 上の付加的な制約は、ユーザが用意した関数経由で使われます。
%   [J,PSF] = DECONVBLIND(...,FUN,P1,P2,...,PN)
%
% FUN (オプション) は、PSF 上の付加的な制約を記述する関数です。FUN を指定
% するには、4つの方法があります。この方法は、function_handle、インライン
% オブジェクトとして @、関数名、または、MATLAB 表現を含んだ文字列を使う方
% 法です。FUN は、各繰り返しの最後でコールされます。FUN は、最初の引数と
% して必ずPSF を使い、その後で、付加的なパラメータP1, P2, ..., PNを受け入
% れることができます。FUN は、一つの引数 PSF のみを出力します。これは、
% INITPSF と同じ大きさで、正であることと、正規化に関する制約を満足します。
%
% NUMIT (オプション) は、繰り返しの最大回数です(デフォルト 10)。
%
% DAMPAR (オプション) は、ダンピングが生じるもので、イメージ I と結果の
% イメージのスレッシュホールド偏差(ポアソンノイズの標準偏差の項で)を指定
% する配列です。繰り返しにより、オリジナルの値から DAMPAR 値内での偏差を
% もつピクセルを小さくします。これは、このようなピクセル内に生じるノイズ
% を低下させ、その他の必要なイメージの詳細を保存します。デフォルトは0(ダ
% ンピングなし)です。
%
% WEIGHT (オプション) は、カメラの中のレコーディングの質を反映するように
% 各ピクセルに割り当てます。悪いピクセルは、ゼロの重み値を割り当てること
% で、排除できます。良いピクセルに重み1を割り当てる代わりに、平坦フィール
% ド補正の総量に従って、重みを調整することができます。デフォルトは、入力
% イメージ I と同じ大きさの単位配列です。
%
% READOUT (オプション) は、付加的なノイズ(たとえば、バックグランドノイズ
% やフォアグランドノイズ)や出力されたカメラノイズの分散に対応した配列で
% す。READOUT は、イメージで使われている単位で記述されます。デフォルトは
% 0です。
%
% 出力イメージ J は、アルゴリズムの中で使われる離散フーリエ変換が起因す
% るリンギングを指名していることに注意してください。DECONVBLIND をコール
% する前に、I = EDGETAPER(I,PSF) を使って、リンギングを低下させてください。% 
% DECONVBLIND は、前もって実行した DECONVBLIND の結果からその後のデコン
% ボリューションの計算を再スタートできることに注意してください。このシン
% タックスを初期化するため、入力 I と INITPSF が、セル配列 {I} と {INI-
% TPSF}に渡される必要があります。そして、出力 J と PSF はセル配列になり、
% 入力配列として、つぎの DECONVBLIND コールの中に渡されます。入力セル配
% 列は、(最初のコールとして)一つの数値配列、または、(DECONVBLIND の前の
% 実行からの出力が存在する場合)4つの数値配列を含ませることができます。出
% 力 J は、J{1}＝I，J{2}ｶﾞ最新の繰り返しの結果のイメージ、J{3}は、一つ前
% のイメージ、J{4} は、繰り返しアルゴリズムで内部的に使われるものです。
%
% クラスサポート
% -------------
% I と INITPSF は、クラス uint8, uint16, double のいずれかです。DAMPAR 
% と READOUT は、入力イメージと同じクラスになる必要があります。他の入
% 力 は、クラス double です。出力イメージ J(または、出力セルの最初の配
% 列)は、入力イメージ I と同じクラスです。出力 PSF は、クラス double で
% す。
%
%   例題
%   -------
%      
%      I = checkerboard(8);
%      PSF = fspecial('gaussian',7,10);
%      V = .0001;
%      BlurredNoisy = imnoise(imfilter(I,PSF),'gaussian',0,V);
%      WT = zeros(size(I));WT(5:end-4,5:end-4) = 1;
%      INITPSF = ones(size(PSF));
%      FUN = inline('PSF + P1','PSF','P1');
%      [J P] = deconvblind(BlurredNoisy,INITPSF,20,10*sqrt(V),WT,FUN,0);
%      subplot(221);imshow(BlurredNoisy);
%                     title('A = Blurred and Noisy');
%      subplot(222);imshow(PSF,[]);
%                     title('True PSF');
%      subplot(223);imshow(J);
%                     title('Deblured Image');
%      subplot(224);imshow(P,[]);
%                     title('Recovered PSF');
%
% 参考：DECONVWNR, DECONVREG, DECONVLUCY, EDGETAPER, PADARRAY,
%       PSF2OTF, OTF2PSF.



%   Copyright 1993-2002 The MathWorks, Inc.  
