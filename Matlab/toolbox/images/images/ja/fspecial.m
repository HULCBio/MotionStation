% FSPECIAL 2次元の指定したタイプのフィルタの作成
% H = FSPECIAL(TYPE) 指定したタイプの2次元フィルタ H を作成します。TYPE
% に対して、可能な値は、つぎのものです。
%
%     'average'   平均化フィルタ
%     'disk'      巡回平均化フィルタ
%     'gaussian'  Gaussian ローパスフィルタ
%     'laplacian' 2次元 Laplacian 演算子を近似するフィルタ
%     'log'       Gaussian フィルタの Laplacian
%     'motion'    モーションフィルタ
%     'prewitt'   Prewitt 水平方向エッジ強調フィルタ
%     'sobel'     Sobel 水平方向エッジ強調フィルタ
%     'unsharp'   鮮明でないコントラストを強調するフィルタ
%
% TYPE に依存して、FSPECIAL は、設定できる付加的なパラメータを使用する
% ことができます。これらのパラメータには、すべてデフォルト値が用意され
% ています。
%
% H = FSPECIAL('average',HSIZE) は、サイズ HSIZE の平均化フィルタ H を
% 戻します。HSIZE は、H の行数と列数を指定するベクトルであるか、または、
% H が正方行列の場合、その大きさを設定するスカラ値です。
% デフォルトの HSIZE は、[3 3] です。
%
% H = FSPECIAL('disk',RADIUS) は、2*RADIUS+1 の大きさの正方行列になる
% 巡回平均化フィルタを戻します。デフォルトの RADIUS は、5です。
%
% H = FSPECIAL('gaussian',HSIZE,SIGMA) は、標準偏差 SIGMA(正)をもつサイ
% ズ HSIZE の点対称 Gaussian ローパスフィルタを戻します。HSIZE は、H の
% 行数と列数を指定するベクトルであるか、または、H が正方行列の場合、そ
% の大きさを設定するスカラ値です。HSIZE のデフォルト値は、[3 3]で、SI-
% GMA のデフォルトは0.5です。
%
% H = FSPECIAL('laplacian',ALPHA) は、2次元の Laplacian 演算子の型に近似
% した3行3列のフィルタです。パラメータ ALPHA は、Laplacian の型をコント
% ロールするもので、0.0と1.0 の間の値です。ALPHA のデフォルト値は、0.2 
% です。
%
% H = FSPECIAL('log',HSIZE,SIGMA) は、標準偏差 SIGMA(正)をもつサイズ HSI-
% ZE の Gaussian フィルタの点対称 Laplacian を出力します。HSIZE は、H の
% 行数と列数を指定するベクトルであるか、または、H が正方行列の場合、その
% 大きさを設定するスカラ値です。HSIZE のデフォルト値は、[5 5]で、SIGMA の
% デフォルトは0.5です。
%
% H = FSPECIAL('motion',LEN,THETA) は、イメージとコンボリューションし、
% LEN ピクセル分、カメラの線形移動を行い、反時計周りに THETA 度の回転し
% た結果を出力します。フィルタは、水平方向と垂直方向への動作を実現するも
% のです。デフォルトの LEN は9で、デフォルトの THETA は0で、これは、水平
% 方向に9ピクセル移動したものに対応します。
%
% H = FSPECIAL('prewitt') は、垂直方向の勾配を近似することにより、水平方
% 向のエッジを強調する3行3列のフィルタを出力します。垂直エッジを強調する
% 必要がある場合、フィルタH を転置 H' してください。
%
%       [1 1 1;0 0 0;-1 -1 -1].
%
% H = FSPECIAL('sobel') は、垂直方向の勾配を近似することにより、平滑化の
% 影響を利用して、水平方向のエッジを強調する3行3列のフィルタを戻します。
% 垂直方向のエッジを強調したい場合、フィルタH を転置 H' を行ってください。
%
%       [1 2 1;0 0 0;-1 -2 -1].
%
% H = FSPECIAL('unsharp',ALPHA) は、3行3列で、コントラストを強調するフィ
% ルタを戻します。FSPECIAL は、パラメータ ALPHA を使って、Laplacian フィ
% ルタの負の部分を利用して、コントラストがはっきりしないフィルタを作成し
% ます。ALPHA は、Laplacian の型をコントロールするもので、0.0 から 1.0 
% の間の値です、デフォルトは、 ALPHA = 0.2 です。
%
% クラスサポート
% -------------
% H は、クラス double です。
%
% 例題
% -------
%      I = imread('saturn.tif');
%      subplot(2,2,1);imshow(I);title('Original Image'); 
%      H = fspecial('motion',50,45);
%      MotionBlur = imfilter(I,H);
%      subplot(2,2,2);imshow(MotionBlur);title('Motion Blurred Image');
%      H = fspecial('disk',10);
%      blurred = imfilter(I,H);
%      subplot(2,2,3);imshow(blurred);title('Blurred Image');
%      H = fspecial('unsharp');
%      sharpened = imfilter(I,H);
%      subplot(2,2,4);imshow(sharpened);title('Sharpened Image');
%       
% 参考：CONV2, EDGE, FILTER2, FSAMP2, FWIND1, FWIND2, IMFILTER.



%   Copyright 1993-2002 The MathWorks, Inc.  
