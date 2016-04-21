% EDGETAPER イメージエッジに沿った不連続にテーパを与えます。
% J = EDGETAPER(I,PSF) は、点像強度関数 PSF を使って、イメージ I のエッ
% ジを不鮮明にします。出力イメージ J は、オリジナルイメージ I とその不
% 鮮明になったバージョンの重み付き和で表わせます。PSF の自己相関関数で
% 決定される重みに関する配列は、中心部がI のものと等しく、エッジの近傍
% では、I を不鮮明にしたバージョンに等しくなるものです。
%
% 関数 EDGETAPER は、離散フーリエ変換を使った、イメージを明瞭化する方法、
% たとえば、DECONWNR, DECONVREG, DECONVLUCY で、リンギングの影響を低減
% します。
%
% PSF のサイズが、任意の次元の中のイメージサイズの半分より小さい必要が
% あります。
%
% クラスサポート  
% -------------
% I と PSF は、クラス uint8, uint16, double のいずれかです。J は、I と
% 同じクラスです。
%
% 例題  
%   -------
%      I   = imread('cameraman.tif');
%      PSF = fspecial('gaussian',60,10); 
%      J  = edgetaper(I,PSF);
%      subplot(1,2,1);imshow(I,[]);title('original image');
%      subplot(1,2,2);imshow(J,[]);title('edges tapered');
%
% 参考：DECONVWNR, DECONVREG, DECONVLUCY, PADARRAY, PSF2OTF, OTF2PSF.



%   Copyright 1993-2002 The MathWorks, Inc.  
