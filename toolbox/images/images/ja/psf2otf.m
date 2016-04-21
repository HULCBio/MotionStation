% PSF2OTF 　点像強度関数を光学伝達関数に変換
% OTF = PSF2OTF(PSF) は、点像強度関数(PSF)配列の高速フーリエ変換を計算
% し、光学伝達関数(OFT)配列を作成します。これは、PSF の中心のズレによる
% 影響を受けません。デフォルトで、OTF 配列は、PSF 配列と同じサイズです。
% 
% OTF = PSF2OTF(PSF,OUTSIZE) は、PSF 配列を、指定したサイズ OUTSIZE の 
% OTF 配列に変換します。OUTSIZE は、任意の次元で、PSF 配列サイズより小さ
% くはなりません。
%
% OTF が、PSF の中心がズレることに影響を受けないことを確かめるには、OUT-
% SIZE に指定した次元と一致するように、PSF2OTF は、PSF 配列にゼロを付加し
% ます。そして、中心のピクセルが、(1,1) の位置に達するまで、PSF 配列を巡
% 回的にシフトします。
%
% この関数は、演算が、FFT を含んでいる場合、イメージのコンボリューション
% /デコンボリューションに使われることに注意してください。
%
% クラスサポート
% -------------
% PSF は、非スパース、数値配列で、OTF は、クラス double です。
%
% 例題
% -------
%      PSF  = fspecial('gaussian',13,1);
%      OTF  = psf2otf(PSF,[31 31]); % PSF --> OTF
%      subplot(1,2,1); surf(PSF); title('PSF');
%      axis square; axis tight
%      subplot(1,2,2); surf(abs(OTF)); title('corresponding |OTF|');
%      axis square; axis tight
%
% 参考： OTF2PSF, CIRCSHIFT, PADARRAY.



%   Copyright 1993-2002 The MathWorks, Inc.  
