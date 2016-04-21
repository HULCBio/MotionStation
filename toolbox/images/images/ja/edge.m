% EDGE   強度イメージ内のエッジの検出
%
% EDGE は、強度またはバイナリイメージ I 入力として取り入れて、I と同じ
% 大きさのバイナリイメージ BW を出力します。ここで、関数は、I の中の
% エッジを検出して1を出力し、それ以外を0とします。
% 
% EDGE は、つぎの6つのエッジ検出法をサポートします。
% 
% Sobel 法は、微係数に Sobel 近似を使ってエッジの検出を行います。I の勾
% 配が最大になる点をエッジとして出力します。
% 
% Prewitt 法は、微係数に Prewitt 近似を使ってエッジの検出を行います。I 
% の勾配が最大になる点をエッジとします。
% 
% Roberts 法は、微係数に Roberts 近似を使ってエッジ検出を行います。I の
% 勾配が最大になる点をエッジとします。
% 
% Gaussian の Laplacian 法は、Gaussian フィルタの Laplacian で、I をフィ
% ルタリングした後、ゼロクロッシング法を使ってエッジ検出を行います。
% 
% zero-cross 法は、ユーザが設定したフィルタで、I をフィルタリングした後
% ゼロクロッシング法を使ってエッジ検出を行います。
% 
% Canny 法は、I の勾配の極大を求めることによりエッジ検出を行います。この
% 勾配計算には、Gaussian フィルタの微係数を使います。この方法では、2つの
% スレッシュホールドを使って、強いエッジと弱いエッジを検出します。そして
% 弱いエッジが強いエッジに接続されている場合に限り、弱いエッジを出力に含
% めます。そのため、この方法は、他の方法に比べてノイズの影響を受けにくく
% より正確に弱いエッジを検出します。
% 
% どの手法を指定するかにより、適用できるパラメータも異なります。手法を指
% 定しない場合は、EDGE は、Sobel 法を使用します。
% 
% Sobel 法
% ------------
% BW = EDGE(I,'sobel') は、Sobel 法を設定します。
% 
% BW = EDGE(I,'sobel',THRESH) は、Sobel 法に対する感度スレッシュホールド
% を設定します。EDGE は、THRESH より弱いエッジをすべて無視します。THRESH
%  を設定しないか、THRESH が空([])である場合、EDGE は、自動的に値を選択
% します。
% 
% BW = EDGE(I,'sobel',THRESH,DIRECTION) は、Sobel 法に方向性を加えます。
% DIRECTION は、'horizontal' エッジ、'vertical' エッジ、'both' (デフォル
% ト)の内、どの方向の検索を実行するかを設定する文字列です。
% 
% [BW,thresh] = EDGE(I,'sobel',...) は、スレッシュホールド値を出力します。
% 
% Prewitt 法
% -------------
% BW = EDGE(I,'prewitt') は、Prewitt 法を設定します。
% 
% BW = EDGE(I,'prewitt',THRESH) は、Prewitt 法に対する感度スレッシュホー
% ルドを設定します。EDGE は、THRESH より弱いエッジをすべて無視します。
% THRESH を設定しないか、THRESH が空([])である場合、EDGE は自動的に値を
% 選択します。
% 
% BW = EDGE(I,'prewitt',THRESH,DIRECTION) は、Prewitt 法に方向性を加えま
% す。DIRECTION は、'horizontal' エッジ、'vertical' エッジ、'both' (デフ
% ォルト)の内、どの方向の検索を実行するかを設定する文字列です。
% 
% [BW,thresh] = EDGE(I,'prewitt',...) は、スレッシュホールド値を出力しま
% す。
% 
% Roberts 法
% -------------
% BW = EDGE(I,'roberts') は、Roberts 法を設定します。
% 
% BW = EDGE(I,'roberts',THRESH) は、Roberts 法に対する感度スレッシュホー
% ルドを設定します。EDGE は、THRESH より弱いエッジをすべて無視します。
% THRESH を設定しないか、THRESH が空([])である場合、EDGE は自動的に値を
% 選択します。
% 
% [BW,thresh] = EDGE(I,'roberts',...) は、スレッシュホールド値を出力しま
% す。
% 
% Gaussian の Laplacian 法
% -------------
% BW = EDGE(I,'log') は、Gaussian の Laplacian 法を設定します。
% 
% BW = EDGE(I,'log',THRESH) は、Gaussian の Laplacian 法に対する感度スレ
% ッシュホールドを設定します。EDGE は、THRESH より弱いエッジをすべて無視
% します。THRESH を設定しないか、THRESH が空([])である場合、EDGE は自動
% 的に値を選択します。
% 
% BW = EDGE(I,'log',THRESH,SIGMA) は、SIGMA を LoG フィルタの標準偏差と
% して使用して、Gaussian の Laplacian 法を設定します。デフォルトの SIGMA
% は2です。そして、フィルタのサイズは N 行 N 列です。ここで、N = CEIL(
% SIGMA*3)*2+1です。
% 
% [BW,thresh] = EDGE(I,'log',...) は、スレッシュホールドを出力します。
% 
% Zero-cross 法
% -------------
% BW = EDGE(I,'zerocross',THRESH,H) は、設定したフィルタ H を使って、
% zero-cross 法を設定します。THRESH が空([])である場合、EDGE は自動的に
% 感度スレッシュホールドを選択します。
% 
% [BW,THRESH] = EDGE(I,'zerocross',...) は、スレッシュホールド値を出力し
% ます。
% 
% Canny 法
% -------------
% BW = EDGE(I,'canny') は、Canny 法を設定します。
% 
% BW = EDGE(I,'canny',THRESH) は、Canny 法に対する感度スレッシュホールド
% を設定します。THRESH は、第1要素が低いスレッシュホールド、第2要素が高
% いスレッシュホールドである2要素ベクトルです。THRESH にスカラを設定する
% 場合、この値を高いスレッシュホールド、0.4*THRESH を低いスレッシュホー
% ルドに設定します。THRESH を設定しないか、THRESH が空([])である場合、
% EDGE は、自動的に低い値と高い値を選択します。
% 
% BW = EDGE(I,'canny',THRESH,SIGMA) は、SIGMA を Gaussian フィルタの標準
% 偏差として使用して、Canny 法を設定します。デフォルトの SIGMA は1です。
% そして、SIGMA に基づいて、このフィルタのサイズを自動的に選択します。
% 
% [BW,thresh] = EDGE(I,'canny',...) は、スレッシュホールド値を2要素ベク
% トルとして出力します。
% 
% クラスサポート
% -------------
% I は、uint8、uint16、または、double のいずれのクラスもサポートしていま
% す。BW は、クラス uint8 です。
% 
% 注意
% -------
% 'log' と 'zerocross' 法に対して、0のスレッシュホールドを設定する場合、
% 出力イメージは閉じたコンター群になります。これは、入力イメージの中でゼ
% ロクロスする部分をすべて含むためです。
% 
% 例題
% -------
% Prewitt 法と Canny 法を使って、rice.tif イメージのエッジ検出を行います。
% 
%       I = imread('rice.tif');
%       BW1 = edge(I,'prewitt');
%       BW2 = edge(I,'canny');
%       imshow(BW1)
%       figure, imshow(BW2)
%
% 参考：FSPECIAL.



%   Copyright 1993-2002 The MathWorks, Inc.  
