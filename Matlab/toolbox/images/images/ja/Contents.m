% Image Processing Toolbox.
% Version 3.2 (R13) 28-Jun-2002
%
% リリース情報
% images/Readme    - カレントバージョンと前のバージョンに関する情報を表示
%
% イメージ表示
% colorbar         - カラーバーの表示(MATLAB 基本モジュールに含まれます)
% getimage         - 軸からイメージデータを取得
% image            - イメージオブジェクトの作成と表示(MATLAB 基本モジュールに
%                    含まれます)
% imagesc          - データをスケーリングし、イメージとして表示(MATLAB 基本モ
%                    ジュールに含まれます)
% immovie          - マルチフレームインデックス付きイメージからムービーの作成
% imshow           - イメージの表示
% montage          - 複数のイメージフレームを一つの長方形モンタージュとして表
%                    示
% movie            - 記録されたムービィフレームを表示(MATLAB 基本モジュールに
%                    含まれます)
% subimage         - 複数イメージを単一の figure に表示
% truesize         - イメージの表示サイズの調整
% warp             - イメージをテクスチャーマップサーフェスに表示
%
% イメージファイルの入出力
% dicominfo        - DICOM メッセージからメタデータを読み込む
% dicomread        - DICOM イメージを読み込む
% dicomwrite       - DICOM イメージを書き込む
% dicom-dict.txt   - DICOM データディクショナリーを含むテキストファイル
% imfinfo          - イメージファイルの情報の取得(MATLAB 基本モジュールに含ま
%                    れます)
% imread           - イメージファイルの読み込み(MATLAB 基本モジュールに含まれ
%                    ます)
% imwrite          - イメージファイルの書き出し(MATLAB 基本モジュールに含まれ
%                    ます)
%
% イメージ算術
% imabsdiff        - 2つのイメージの差の絶対値を計算
% imadd            - 2つのイメージの加算、または、定数をイメージに加算
% imcomplement     - イメージの補集合
% imdivide         - 2つのイメージの除算、または、イメージを定数で除算
% imlincomb        - イメージの線形結合を計算
% immultiply       - 2つのイメージの乗算、または、イメージと定数の乗算
% imsubtract       - 2つのイメージの減算、または、イメージから定数の減算
%
% 幾何学的変換
% checkerboard     - チェックボードイメージの作成
% findbounds       - 幾何学的変換に対する出力範囲の検出
% fliptform        - 構造体 TFORM の入力と出力の反転
% imcrop           - イメージの抽出
% imresize         - イメージのリサイズ
% imrotate         - イメージの回転
% imtransform      - 幾何学的変換をイメージに適用
% makeresampler    - resampler 構造体の作成
% maketform        - 幾何学的変換構造体(TFORM)の作成
% tformarray       - 幾何学的変換を N-次元配列に適用
% tformfwd         - フォワード幾何学的変換を適用
% tforminv         - 逆幾何学的変換を適用
%
% イメージレジストレーション
% cpstruct2pairs   - CPSTRUCT をコントロールポイントの正しい組に変換
% cp2tform         - コントロールポイントの組から幾何学的変換を推定
% cpcorr           - 相互相関を使って、コントロールポイントの位置を調整
% cpselect         - コントロールポイントの選択ツール
% normxcorr2       - 正規化した2次元の相互相関
%
% ピクセル値と統計
% corr2            - 2次元相関係数の計算
% imcontour        - イメージデータコンタープロットの作成
% imhist           - イメージデータのヒストグラムの表示
% impixel          - ピクセルカラー値の決定
% improfile        - ラインセグメントに沿ったピクセル値の断面図の計算
% mean2            - 行列要素の平均値の計算
% pixval           - イメージピクセル情報の表示
% regionprops      - イメージ領域のプロパティの測定
% std2             - 行列要素の標準偏差の計算
%
% イメージの解析
% edge             - 強度イメージでのエッジの検出
% qtdecomp         - 4分割ツリー分解
% qtgetblk         - 4分割ツリー分解でのブロック値の取得
% qtsetblk         - 4分割ツリー分解でのブロック値の設定
%
% イメージの強調
% histeq           - ヒストグラムの均等化を使って、コントラストの強調
% imadjust         - イメージの強度値、または、カラーマップの調整
% imnoise          - ノイズをイメージに付加
% medfilt2         - 2次元メディアンフィルタ操作
% ordfilt2         - 2次元の順位付けされた統計的なフィルタ操作
% stretchlim       - イメージのコントラストを大きくする境界の検出
% wiener2          - 2次元適応ノイズ除去フィルタ操作
%
% 線形フィルタリング
% convmtx2         - 2次元コンボリューション行列の計算
% fspecial         - ユーザ定義のフィルタの作成
% imfilter         - 2次元、N 次元のフィルタ
%
% 線形2次元フィルタ設計
% freqspace        - 2次元周波数応答を計算する周波数点の決定(MATLAB 基本モジュ
%                    ールに含まれます)
% freqz2           - 2次元周波数応答の計算
% fsamp2           - 周波数サンプル法を使った2次元 FIR フィルタの設計
% ftrans2          - 周波数変換法を使った2次元 FIR フィルタの設計
% fwind1           - 1次元ウィンドウ法を使った2次元 FIR フィルタの設計
% fwind2           - 2次元ウィンドウ法を使った2次元 FIR フィルタの設計
%
% イメージの明瞭化 
% deconvblind      - Blind デコンボリューションを使った不明瞭イメージの
% 　　　　　　　　　 明瞭化
% deconvlucy       - Lucy-Richardson 法を使って、イメージの明瞭化
% deconvreg        - 正則化フィルタを使って、イメージの明瞭化
% deconvwnr        - Wiener フィルタを使って、イメージの明瞭化
% edgetaper        - 点像強度関数を使って、エッジにテーパを適用
% otf2psf          - 光学的伝達関数を点像強度関数に変換
% psf2otf          - 点像強度関数を光学的伝達関数に変換
%
% イメージ変換
% dct2             - 2次元離散コサイン変換
% dctmtx           - 離散コサイン変換行列の計算
% fft2             - 2次元高速フーリエ変換(MATLAB 基本モジュールに含まれます)
% fftn             - N 次元高速フーリエ変換(MATLAB 基本モジュールに含まれます)
% fftshift         - FFT の出力結果の並べ替え(MATLAB 基本モジュールに含まれま
%                    す)
% idct2            - 2次元逆離散コサイン変換
% ifft2            - 2次元高速逆フーリエ変換(MATLAB 基本モジュールに含まれます)
% ifftn            - N 次元高速逆フーリエ変換(MATLAB 基本モジュールに含まれます)
% iradon           - 逆ラドン変換
% phantom          - ヘッドファントムイメージの作成
% radon            - ラドン変換
%
% 近傍処理とブロック処理
% bestblk          - ブロック処理用のブロックサイズの選択
% blkproc          - イメージにブロック処理を適用
% col2im           - 行列列をブロックに並び替え
% colfilt          - 列適用関数を使って、近傍処理を適用
% im2col           - イメージブロックを列に並び替え
% nlfilter         - 一般的なスライディング近傍操作を実行
%
% 形態学的操作 (強度イメージとバイナリイメージ)
% conndef          - デフォルトの結合配列
% imbothat         - bottom-hat フィルタ操作の実現
% imclearborder    - イメージの境界に接続している明るい構造の抑制
% imclose          - イメージのクローズ処理
% imdilate         - イメージの膨張
% imerode          - イメージの縮退
% imextendedmax    - Extended-maxima 変換
% imextendedmin    - Extended-minima 変換
% imfill           - イメージ領域やホールの塗り潰し
% imhmax           - H-maxima 変換
% imhmin           - H-minima 変換
% imimposemin      - 最小値の割り当て
% imopen           - イメージのオープン処理
% imreconstruct    - 形態学的再構成
% imregionalmax    - 地域的な最大値の集まり
% imregionalmin    - 地域的な最小値の集まり
% imtophat         - tophat フィルタ操作の実現
% watershed        - Watershed 変換
%
% 形態学的操作 (バイナリイメージ)
% applylut         - ルックアップテーブルを使って、近傍操作を実行
% bwarea           - バイナリイメージ内のオブジェクトの面積計算
% bwareaopen       - バイナリ領域のオープン操作 (小さいオブジェクトを削除)
% bwdist           - バイナリイメージの距離変換の計算
% bweuler          - バイナリイメージの Euler 数の計算
% bwhitmiss        - バイナリ hit-miss 演算
% bwlabel          - 2次元バイナリイメージ内で結合している要素のラベル付け
% bwlabeln         - N-次元バイナリイメージ内で、結合している要素のラベル
%                    付け
% bwmorph          - バイナリイメージ上での形態学的操作の適用
% bwpack           - バイナリイメージのパック
% bwperim          - バイナリイメージ内であるオブジェクトの周囲の決定
% bwselect         - バイナリイメージ内でオブジェクトの選択
% bwulterode       - 最終的な縮退
% bwunpack         - バイナリイメージの圧縮解除
% makelut          - applylut で使用するルックアップテーブルの作成
%
% 構造化要素(STREL)の作成と取り扱い
% getheight        - strel 高さの取得
% getneighbors     - strel 近傍のオフセットの位置と高さの取得
% getnhood         - strel 近傍の取得
% getsequence      - 分解された strel 群の取得
% isflat           - 平坦な strel の検出
% reflect          - 中心の関して、対称な strel の作成 (180°回転)
% strel            - 形態学的な構造化要素の作成
% translate        - strel の変換
%
% 領域単位の処理
% roicolor         - カラーをベースに対象領域の選択
% roifill          - 任意の領域内で、平滑に内挿
% roifilt2         - 対象領域のフィルタ処理
% roipoly          - 対象領域を多角形で選択
%
% カラーマップ操作
% brighten         - カラーマップの明るさの変更(MATLAB 基本モジュールに含まれ
%                    ます)
% cmpermute        - カラーをカラーマップに並び替え
% cmunique         - ユニークなカラーマップカラーとそれに対応するイメージの検
%                    出
% colormap         - カラールックアップテーブルの設定、または、取得(MATLAB 基
%                    本モジュールに含まれます)
% imapprox         - インデックス付きイメージデータを少ないカラーで近似
% rgbplot          - RGB カラーマップ要素のプロット(MATLAB 基本モジュールに含
%                    まれます)
%
% カラー空間の変換
% hsv2rgb          - HSV 値を RGB カラー空間に変換(MATLAB 基本モジュール
%                    に含まれます)
% ntsc2rgb         - NTSC 値を RGB カラー空間に変換
% rgb2hsv          - RGB 値を HSV カラー空間に変換(MATLAB 基本モジュール
%                    に含まれます)
% rgb2ntsc         - RGB 値を NTSC カラー空間に変換
% rgb2ycbcr        - RGB 値を YCBCR カラー空間に変換
% ycbcr2rgb        - YCBCR 値を RGB カラー空間に変換
%
% 配列演算
% circshift        - 配列を巡回的にシフト(MATLAB 基本モジュールに含まれます)
% padarray         - 配列の付加
%
% イメージタイプとタイプの変換
% dither           - ディザリングを使って、イメージの変換
% gray2ind         - 強度イメージからインデックス付きイメージに変換
% grayslice        - スレッシュホールド法を使って、強度イメージからインデックス
%                    付きイメージに変換
% graythresh       - Otsu 法を使って、グローバルイメージのスレッシュホールドを
%                    計算
% im2bw            - スレッシュホールド法を使って、イメージをバイナリイメージ
%                    に変換
% im2double        - イメージ配列を倍精度に変換
% im2java          - イメージをJavaイメージに変換(MATLAB 基本モジュールに
%                    含まれます)
% im2uint8         - イメージ配列を8ビット符号なし整数に変換
% im2uint16        - イメージ配列を16ビット符号なし整数に変換
% ind2gray         - インデックス付きイメージを強度イメージに変換
% ind2rgb          - インデックス付きイメージを RGB イメージに変換(MATLAB 基本
%                    モジュールに含まれます)
% isbw             - バイナリイメージの検索
% isgray           - 強度イメージの検索
% isind            - インデックス付きイメージの検索
% isrgb            - RGB イメージの検索
% label2rgb        - ラベル化行列を RGB イメージに変換
% mat2gray         - 行列を強度イメージに変換
% rgb2gray         - RGB イメージ、または、カラーマップをグレースケールに変換
% rgb2ind          - RGB イメージをインデックス付きイメージに変換
%
% ツールボックスの優先順位
% iptgetpref       - Image Processing Toolbox の優先順位の取得
% iptsetpref       - Image Processing Toolbox の優先順位の設定
%
% デモンストレーション
% dctdemo          - 2次元 DCT イメージの圧縮に関するデモ
% edgedemo         - エッジの検出のデモ
% firdemo          - 2次元 FIR フィルタ設計と処理のデモ
% imadjdemo        - 強度の調整とヒストグラムの均等化のデモ
% landsatdemo      - Landsat のカラー合成のデモ
% nrfiltdemo       - ノイズ除去フィルタ操作のデモ
% qtdemo           - 4分割分解のデモ
% roidemo          - 対象領域のみの処理の適用デモ
%
% スライドショー
% ipss001          - 鋼鉄の粒子の領域のラベリング
% ipss002          - 特徴ベースの論理
% ipss003          - 一様でない照度の補正
%
% 拡張デモ
% ipexindex        - 拡張した例題のインデックス
% ipexsegmicro     - 微細構造を検出するためのセグメント化
% ipexsegcell      - 細胞検出のためのセグメント化
% ipexsegwatershed - Watershed セグメント化
% ipexgranulometry - 星の大きさの分布
% ipexdeconvwnr    - Wiener フィルタによる明瞭化
% ipexdeconvreg    - 正則化による明瞭化
% ipexdeconvlucy   - Lucy-Richardson法による明瞭化
% ipexdeconvblind  - Blind デコンボリューションによる明瞭化
% ipextform        - イメージ変換ギャラリ
% ipexshear        - イメージの付加と共有
% ipexmri          - 3-D MRI スライス
% ipexconformal    - 等角写像 
% ipexnormxcorr2   - 正規化した相互相関
% ipexrotate       - 回転とスケールの回復
% ipexregaerial    - 航空写真のレジストレーション



%   Copyright 1993-2002 The MathWorks, Inc.
