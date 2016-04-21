% DECONVREG 正則化フィルタを使って、イメージの再構成
% J = DECONVREG(I,PSF) は、正則化フィルタアルゴリズムを使って、イメージ 
% I を分解し、明瞭化されたイメージ J を出力します。仮定は、イメージ I 
% は、真のイメージと点像強度関数 PSF をコンボリューションし、ノイズを付
% 加したものと考えます。アルゴリズムは、推定したイメージと真のイメージの
% 間の差が、イメージの平滑さを変更させない条件のもとで、最小二乗誤差の意
% 味で制約付き最適化になります。
%
% 再構成の質を改良するために、つぎの付加的なパラメータを渡すことができま
% す。(中間のパラメータが未知の場合、[]が使われます)
%   J = DECONVREG(I,PSF,NP)
%   J = DECONVREG(I,PSF,NP,LRANGE)
%   J = DECONVREG(I,PSF,NP,LRANGE,REGOP), ここで、
%
%   NP     (オプション) は、付加ノイズのパワーです。デフォルトは0です。
%
% LRANGE (オプション) は、最適解を求めるためにサーチする範囲を指定するベ
% クトルです。アルゴリズムは、レンジ LRANGE 内で、最適 Lagrange 乗数 LAG-
% RA を求めます。LRANGE がスカラの場合、LAGRAが与えられ、LRANGE と等しく
% なると仮定します。そのために、NP 値は、無視されます。デフォルトは、[1e-9
% 1e9]です。
%
% REGOP  (オプション) は、デコンボリューションに制約を課す正則化演算子で
% す。イメージの平滑さを保持したまま、Laplacian 正則化演算子が、デフォル
% トで使われます。REGOP 配列次元は、イメージの次元以下で、あるシングルト
% ンでない次元は、PSF のシングルトンでない次元に対応する必要があります。
%
% [J, LAGRA] = DECONVREG(I,PSF,...) は、再構成されたイメージ J に加え、
% Lagrange 乗数の値 LAGRA を出力します。
%
% 出力イメージ J は、アルゴリズムの中で使われる離散フーリエ変換が起因する
% リンギングを指名していることに注意してください。DECONVREG をコールする
% 前に、I = EDGETAPER(I,PSF) を使って、リンギングを低下させてください。
%
% クラスサポート
% -------------
% I と PSF は、クラス uint8, uint16, double のいずれかです、他の入力は、
% クラス double で、J は I と同じクラスです。
%
% 例題
% -------
%
%      I = checkerboard(8);
%      PSF = fspecial('gaussian',7,10);
%      V = .01;
%      BlurredNoisy = imnoise(imfilter(I,PSF),'gaussian',0,V);
%      NP = V*prod(size(I));% ノイズのパワー
%      [J LAGRA] = deconvreg(BlurredNoisy,PSF,NP);
%      subplot(221);imshow(BlurredNoisy);
%                     title('A = Blurred and Noisy');
%      subplot(222);imshow(J);
%                     title('[J LAGRA] = deconvreg(A,PSF,NP)');
%      subplot(223);imshow(deconvreg(BlurredNoisy,PSF,[],LAGRA/10));
%                     title('deconvreg(A,PSF,[],0.1*LAGRA)');
%      subplot(224);imshow(deconvreg(BlurredNoisy,PSF,[],LAGRA*10));
%                     title('deconvreg(A,PSF,[],10*LAGRA)');
%
% 参考：DECONVWNR, DECONVLUCY, DECONVBLIND, EDGETAPER, PADARRAY, 
%       PSF2OTF, OTF2PSF.



%   Copyright 1993-2002 The MathWorks, Inc.  
