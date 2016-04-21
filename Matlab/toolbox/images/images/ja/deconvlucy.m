% DECONVLUCY Lucy-Richardson アルゴリズムを使って、イメージの再構成 
% J = DECONVLUCY(I,PSF) は、Lucy-Richardson アルゴリズムを使って、イメー
% ジ I を分解し、明瞭化されたイメージ J を出力します。イメージ I が真のイ
% メージと点像強度関数 PSF とのコンボリューションに(可能性として)ノイズを
% 付加することにより作成していると考えています。
%
% 再構成の質を改良するために、つぎの付加的なパラメータを渡すことができま
% す。(中間のパラメータが未知の場合、[]が使われます)
%   J = DECONVLUCY(I,PSF,NUMIT)
%   J = DECONVLUCY(I,PSF,NUMIT,DAMPAR)
%   J = DECONVLUCY(I,PSF,NUMIT,DAMPAR,WEIGHT)
%   J = DECONVLUCY(I,PSF,NUMIT,DAMPAR,WEIGHT,READOUT)
%   J = DECONVLUCY(I,PSF,NUMIT,DAMPAR,WEIGHT,READOUT,SUBSMPL), where
%
%   NUMIT   (オプション) は、繰り返し最大回数 (デフォルトは10)
%
% DAMPAR (オプション) は、ダンピングが生じるもので、イメージ I と結果のイ
% メージのスレッシュホールド偏差(ポアソンノイズの標準偏差の項で)を指定す
% る配列です。繰り返しにより、オリジナルの値から DAMPAR 値内での偏差をも
% つピクセルを小さくします。これは、このようなピクセル内に生じるノイズを
% 低下させ、その他の必要なイメージの詳細を保存します。デフォルトは0(ダン
% ピングなし)です。
%
% WEIGHT (オプション) は、カメラの中のレコーディングの質を反映するように
% 各ピクセルに割り当てます。悪いピクセルは、ゼロの重み値を割り当てること
% で、排除できます。良いピクセルに重み1を割り当てる代わりに、平坦フィー
% ルド補正の総量に従って、重みを調整することができます。デフォルトは、入
% 力イメージ I と同じ大きさの単位配列です。
%
% READOUT (オプション) は、付加的なノイズ(たとえば、バックグランドノイズ
% やフォアグランドノイズ)や出力されたカメラノイズの分散に対応した配列で
% す。READOUT は、イメージで使われている単位で記述されます。デフォルトは
% 0です。
%
% SUBSMPL (オプション) は、サブサンプリングを定義し、PSF がイメージより 
% SUBSMPL 倍、細かいグリッド上で与えられる場合に使われます。デフォルトは
% 1です。
%
% 出力イメージ J は、アルゴリズムの中で使われる離散フーリエ変換が起因する
% リンギングを指名していることに注意してください。DECONVLUCY をコールする
% 前に、I = EDGETAPER(I,PSF) を使って、リンギングを低下させてください。
%
% DECONVLUCYは、前もって実行した DECONVLUCY の結果からその後のデコンボリ
% ューションの計算を再スタートできることに注意してください。このシンタッ
% クスを初期化するため、入力 I と INITPSF が、セル配列 {I} と {INITPSF}
% に渡される必要があります。そして、出力 J と PSF はセル配列になり、入力
% 配列として、つぎの DECONVLUCY コールの中に渡されます。入力セル配列は、
% (最初のコールとして)一つの数値配列、または、(DECONVLUCY の前の実行から
% の出力が存在する場合)4つの数値配列を含ませることができます。出力 J は、
% J{1}＝I，J{2}ｶﾞ最新の繰り返しの結果のイメージ、J{3}は、一つ前のイメー
% ジ、J{4} は、繰り返しアルゴリズムで内部的に使われるものです。
%
% クラスサポート
% -------------
% I と PSF は、クラス uint8, uint16, double のいずれかです。DAMPAR と
% READOUT は、入力イメージと同じクラスになる必要があります。他の入力 は、
% クラス double です。出力イメージ J(または、出力セルの最初の配列)は、入
% 力イメージ I と同じクラスです。
%
% 例題
% -------
%
%      I = checkerboard(8);
%      PSF = fspecial('gaussian',7,10);
%      V = .0001;
%      BlurredNoisy = imnoise(imfilter(I,PSF),'gaussian',0,V);
%      WT = zeros(size(I));WT(5:end-4,5:end-4) = 1;
%      J1 = deconvlucy(BlurredNoisy,PSF);
%      J2 = deconvlucy(BlurredNoisy,PSF,20,sqrt(V));
%      J3 = deconvlucy(BlurredNoisy,PSF,20,sqrt(V),WT);
%      subplot(221);imshow(BlurredNoisy);
%                     title('A = Blurred and Noisy');
%      subplot(222);imshow(J1);
%                     title('deconvlucy(A,PSF)');
%      subplot(223);imshow(J2);
%                     title('deconvlucy(A,PSF,NI,DP)');
%      subplot(224);imshow(J3);
%                     title('deconvlucy(A,PSF,NI,DP,WT)');
%
% 参考：DECONVWNR, DECONVREG, DECONVBLIND, EDGETAPER, PADARRAY, 
%       PSF2OTF, OTF2PSF.



%   Copyright 1993-2002 The MathWorks, Inc.  
