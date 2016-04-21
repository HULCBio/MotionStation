% Signal Processing Toolbox 
% Version 6.2 (R14) 05-May-2004 
%
% フィルタ解析
% abs        - 絶対値
% angle      - 位相角
% filternorm - ディジタルフィルタの2-ノルムまたはinf-ノルムを計算
% freqs      - アナログフィルタの周波数応答
% freqspace  - 周波数応答のための周波数データ列の作成
% freqz      - ディジタルフィルタの周波数応答
% freqzplot  - 周波数応答データのプロット
% fvtool     - フィルタ視覚化ツール
% grpdelay   - 群遅延
% impz       - ディジタルフィルタのインパルス応答
% phasez     - ディジタルフィルタの位相応答
% phasedelay - ディジタルフィルタの位相遅延
% unwrap     - 位相角の連続性
% zerophase  - 実際のフィルタのゼロ位相応答
% zplane     - 零点- 極のプロット
%
%フィルタの実現
% conv       - コンボリューション
% conv2      - 2次元コンボリューション
% deconv     - デコンボリューション、多項式の除算
% fftfilt    - オーバラップ法を使ったFFTベースFIRフィルタリング
% filter     - 巡回型、非巡回型フィルタによるデータのフィルタリング
% filter2     - 2次元ディジタルフィルタ
% filtfilt   - ゼロ位相ディジタルフィルタリング
% filtic     - 関数filterに対する初期値の設定
% latcfilt   - ラティスフィルタとラティス－ラダーフィルタの実現
% medfilt1   - 1次元メディアンフィルタ
% sgolayfilt - Savitzky-Golay フィルタ実現
% sosfilt    - 2次型構造のIIRフィルタ実現
% upfirdn    - アップサンプル、FIR フィルタ、ダウンサンプル
%
% FIR フィルタ設計
% convmtx    - コンボリューション行列
% cremez     - 複素数かつ非線形位相の等リップルFIRフィルタ設計
% fir1       - ウィンドウベースの有限インパルス応答フィルタの設計
%              (標準応答)
% fir2       - ウィンドウベースの有限インパルス応答フィルタの設計
%             (任意応答)
% fircls     - 複数帯域フィルタに対する条件付き最小二乗 FIRフィルタの設
%              計
% fircls1    - ローパスおよびハイパス線形位相 FIRフィルタに対する条件付
%              き最小二乗 FIRフィルタの設計
% firgauss   - FIR Gaussian ディジタルフィルタ設計
% firls      - 最小二乗線形位相FIRフィルタの設計
% firrcos    - コサインロールオフFIRフィルタの設計
% intfilt    - 補間FIRフィルタの設計
% kaiserord  - Kaiser ウィンドウを使ったFIRフィルタのパラメータ推定
% remez      - Parks-McClellan 最適FIRフィルタ設計
% remezord   - Parks-McClellan 最適FIRフィルタ次数推定
% sgolay     - Savitzky-Golay FIRフィルタ設計
%
% IIR ディジタルフィルタ設計
% butter     - Butterworth フィルタの設計
% cheby1     - Chebyshev I 型フィルタの設計(通過帯域リップル)
% cheby2     - Chebyshev II 型フィルタの設計(遮断帯域リップル)
% ellip      - 楕円フィルタの設計
% maxflat    - 汎用ディジタル Butterworth フィルタの設計
% yulewalk   - 巡回型ディジタルフィルタの設計
%
% IIR フィルタの次数の推定
% buttord    - Butterworth フィルタの次数推定
% cheb1ord   - Chebyshev I型フィルタの次数推定
% cheb2ord   - Chebyshev II型フィルタの次数推定
% ellipord   - 楕円フィルタの次数推定
%
% アナログローパスプロトタイプ設計
% besselap   - Bessel アナログローパスフィルタのプロトタイプ
% buttap     - Butterworth アナログローパスフィルタのプロトタイプ
% cheb1ap    - Chebyshev I型アナログローパスフィルタのプロトタイプ
%              (通過帯域リップル)
% cheb2ap    - Chebyshev II型アナログローパスフィルタのプロトタイプ
%              (遮断帯域リップル)
% ellipap    - 楕円アナログローパスフィルタのプロトタイプ
%
% アナログフィルタ設計
% besself    - Bessel アナログフィルタの設計
% butter     - Butterworth フィルタの設計
% cheby1     - Chebyshev I 型フィルタの設計
% cheby2     - Chebyshev II 型フィルタの設計
% ellip      - 楕円フィルタの設計
%
% アナログ周波数変換
% lp2bp      - ローパスフィルタプロトタイプをバンドパスアナログフィルタ
%              へ変換
% lp2bs      - ローパスフィルタプロトタイプをバンドストップアナログフィ
%              ルタへ変換
% lp2hp      - ローパスフィルタプロトタイプをハイパスアナログフィルタへ
%              変換
% lp2lp      - ローパスフィルタプロトタイプをローパスアナログフィルタへ
%              変換
%
% フィルタの離散化
% bilinear   - 双一次変換を使った変数のマッピング(設定周波数について、マ
%              ッピング前後で、応答を合わせるオプション付き)
% impinvar   - アナログからディジタルフィルタ変換へのインパルス不変応答
%              法
%
% 線形システム変換
% latc2tf    - ラティス、または、ラティス-ラダーフィルタから伝達関数型へ
%              の変換
% polystab   - 多項式の安定化
% polyscale  - 多項式の根のスケーリング 
% residuez   - z変換での部分分数変換
% sos2ss     - 2次型構造から状態空間型への変換
% sos2tf     - 2次型構造から伝達関数型への変換
% sos2zp     - 2次型構造から零点－極型への変換
% ss2sos     - 状態空間型から2次型構造への変換
% ss2tf      - 状態空間型から伝達関数型への変換
% ss2zp      - 状態空間型から零点－極型への変換
% tf2latc    - 伝達関数型からラティス-ラダーフィルタへの変換
% tf2sos     - 伝達関数型から2次型構造への変換
% tf2ss      - 伝達関数型から状態空間型への変換
% tf2zpk     - 離散時間伝達関数型から零点－極型への変換
% zp2sos     - 零点－極型から2次型構造への変換
% zp2ss      - 零点－極型から状態空間型への変換
% zp2tf      - 零点－極型から伝達関数型への変換
%
% ウィンドウ
% bartlett   - Bartlett ウィンドウ
% barthannwin    - 修正Bartlett-Hanningウィンドウ 
% blackman   - Blackman ウィンドウ
% blackmanharris - 最小4-項Blackman-Harrisウィンドウ
% boxcar     - 箱型ウィンドウ
% chebwin    - Chebyshev ウィンドウ
% gausswin   - Gaussianウィンドウ
% hamming    - Hamming ウィンドウ
% hann       - Hann ウィンドウ
% kaiser     - Kaiser ウィンドウ
% nuttallwin - Nuttallの定義の最小4-項Blackman-Harrisウィンドウ
% parzenwin  - Parzen (de la Valle-Poussin) ウィンドウ
% rectwin    - 長方形のウィンドウ
% triang     - 三角ウィンドウ
% tukeywin   - Tukeyウィンドウ
% wvtool     - ウィンドウ視覚化ツール
% window     - Window関数ゲートウェイ
%
% 変換
% bitrevorder - 入力をビット反転した順序に並べ替え
% czt        - Chirp-z 変換
% dct        - 離散コサイン変換(DCT)
% dftmtx     - 離散フーリエ変換行列
% fft        - 1次元高速フーリエ変換
% fft2       - 2次元高速フーリエ変換
% fftshift   - fftとfft2の出力の並べ替え
% goertzel   - 2次Goertzelアルゴリズム
% hilbert    - Hilbert 変換
% idct       - 逆離散コサイン変換
% ifft       - 1次元逆高速フーリエ変換
% ifft2      - 2次元逆高速フーリエ変換
%
% セプストラム解析
% cceps      - 複素セプストラム解析
% icceps     - 逆複素セプストラム
% rceps      - 実数セプストラムと最小位相復元
%
% 統計的な信号処理
% cohere     - 2つの信号間の二乗コヒーレンス関数の推定
% corrcoef   - 相関係数行列
% corrmtx    - 自己相関行列
% cov        - 共分散行列
% csd        - 2つの信号の相互スペクトル密度(CSD)の推定
% pcov       - 共分散法を使ったパワースペクトルの推定
% peig       - 固有ベクトル法を使ったパワースペクトルの推定
% pmcov      - 修正共分散法を使ったパワースペクトルの推定
% pburg      - Burg 法を使ったパワースペクトルの推定
% periodogram - ピリオドグラム法を使ったパワースペクトルの推定
% pmtm       - Thomson の Multitaper 法(MTM)を使ったパワースペクトルの推
%              定
% pmusic     - MUSIC 法を使ったパワースペクトルの推定 
% psdplot    - パワースペクトル密度データのプロット
% pyulear    - Yule-Walker AR 法を使ったパワースペクトルの推定
% pwelch     - Welch 法を使ったパワースペクトルの推定
% rooteig    - 固有ベクトルアルゴリズムを使った調和関数の周波数とパワー
%              の計算
% rootmusic  - MUSIC アルゴリズムをを使った調和関数の周波数とパワーの計
%              算
% tfe        - 入力と出力から伝達関数の推定
% xcorr      - 相互相関関数の推定
% xcorr2     - 2次元の相互相関関数の推定
% xcov       - 相互共分散関数(データ列から平均値を削除した相互相関)の推
%              定
%
% パラメトリックモデリング
% arburg     - Burg 法を使ったARモデルパラメータの推定
% arcov      - 共分散法を使ったARモデルパラメータの推定
% armcov     - 修正共分散法を使ったARモデルパラメータの推定
% aryule     - Yule-Walker 法を使ったARモデルパラメータの推定
% ident      - System Identification Toolbox 参照
% invfreqs   - 周波数データから連続時間(アナログ)フィルタの同定
% invfreqz   - 周波数データから離散時間(ディジタル)フィルタの同定
% prony      - 時間領域IIRフィルタ設計のための Prony 法
% stmcb      - Steiglitz-McBride 反復法を使った線形モデル
%
% 線形システム変換
% ac2rc      - 自己相関列を反射係数に変換
% ac2poly    - 自己相関列を予測多項式に変換
% is2rc      - 逆サインパラメータを反射係数に変換
% lar2rc     - 面積を対数比で表したものを反射係数に変換
% levinson   - Levinson-Durbin 帰納法
% lpc        - 自己相関法を使った線形予測係数の算出
% lsf2poly   - 線スペクトルの周波数を予測多項式に変換
% poly2ac    - 予測多項式を自己相関列に変換
% poly2lsf   - 予測多項式を線スペクトルの周波数に変換
% poly2rc    - 予測多項式を反射係数に変換
% rc2ac      - 反射係数を自己相関列に変換
% rc2is      - 反射係数を逆サインパラメータに変換
% rc2lar     - 反射係数を面積を対数比で表したものに変換
% rc2poly    - 反射係数を予測多項式に変換
% rlevinson  - 逆Reverse Levinson-Durbin 帰納法
% schurrc    - Schur アルゴリズム
%
% マルチレート信号処理
% decimate   - 間引きによりサンプリング間隔を広げる
% downsample - 入力信号のダウンサンプリング
% interp     - リサンプリング(内挿)
% interp1    - 1次元データの補間(MATLAB Toolbox)
% resample   - 任意のファクタによるサンプリングレートの変更
% spline     - キュービックスプライン補間
% upfirdn    - FIRフィルタの適用とサンプリングレートの変換
% upsample   - 入力信号のアップサンプリング
%
% 波形の生成
% chirp      - 時間と共に変化する周波数をもつコサイン波発生器
% diric      - Dirichlet 関数または周期的な sinc 関数
% gauspuls   - Gaussian 変調正弦波パルス発生器
% gmonopuls  - Gaussian モノパルス発生器
% pulstran   - Pulse 列発生器
% rectpuls   - サンプリングされた周期性をもたない矩形パルス発生器
% sawtooth   - ノコギリ波 
% sinc       - Sinc 波、または、sin(π*x)/(π*x) 関数の発生器
% square     - 矩形波発生器
% tripuls    - サンプリングされた周期性をもたない三角波発生器
% vco        - 電圧制御振動発生器
%
% 特殊な演算
% buffer     - 信号ベクトルをデータフレーム行列にバッファリング
% cell2sos    - セル配列を2次型の行列に変換
% cplxpair   - 複素数を複素共役の組に並び替え
% decimate   - リサンプリング(間引き)
% demod      - 通信シミュレーションのための復調
% dpss       - 離散扁長回転楕円体型
% dpssclear  - 離散扁長回転楕円体型をデータベースから削除
% dpssdir    - 離散扁長回転楕円体型データベースディレクトリ
% dpssload   - 離散扁長回転楕円体型をデータベースからロード
% dpsssave   - 離散扁長回転楕円体型をデータベースへの保存 
% eqtflength - 離散時間伝達関数の長さを等しくする
% modulate   - 通信シミュレーションのための変調
% seqperiod  - ベクトル中の反復列の最小長さを探索
% sos2cell   - 2次型の行列をセル配列に変換
% specgram   - 時間に依存した周波数解析(スペクトログラム)
% stem       - 離散データ列のプロット
% strips     - Strip プロット
% udecode    - 入力の一様復号化
% uencode    - 入力を N ビットで一様量子化と符号化
%
% グラフィカルユーザインタフェース
% fdatool     - フィルタ設計解析ツール
% sptool      - 信号処理ツール
% wintool     - ウィンドウの設計と解析ツール
%
% 参考：SIGDEMOS, AUDIO, FILTERDESIGN(Filter Design Toolbox).



% Generated from Contents.m_template revision 1.9
% Copyright 1988-2004 The MathWorks, Inc. 
