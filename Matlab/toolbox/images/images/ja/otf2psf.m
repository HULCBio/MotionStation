% OTF2PSF 光学伝達関数を点像強度関数に変換 
% PSF = OTF2PSF(OTF) は、光学伝達関数(OTF)配列の逆高速フーリエ変換(IFFT)
% を計算し、原点を中心とした点像強度関数(PSF)を作成します。デフォルトで
% は、PSF は OTF と同じサイズです。
%
% PSF = OTF2PSF(OTF,OUTSIZE) は、指定したサイズ OUTSIZE の PSF 配列に、
% OTF 配列を変換します。OUTSIZE は、任意の次元で、OTF 配列のサイズを超
% えてはいけません。
%
% PSF の中心を原点に配置するには、OTF2PSF は、出力配列の値を、(1,1)要素
% が、中心の位置に達するように巡回的にシフトします。そして、結果を、OUT-
% SIZE で設定された次元に一致するように抽出します。
%
% この関数は、演算が、FFT を含んでいる場合、イメージのコンボリューショ
% ン/デコンボリューションに使われることに注意してください。
%
% クラスサポート
% -------------
% OTF は、任意の非スパース、数値配列で、PSF はクラス double です。
%
% 例題
% -------
%      PSF  = fspecial('gaussian',13,1);
%      OTF  = psf2otf(PSF,[31 31]); % PSF --> OTF
%      PSF2 = otf2psf(OTF,size(PSF)); % OTF --> PSF2
%      subplot(1,2,1); surf(abs(OTF)); title('|OTF|');
%      axis square; axis tight
%      subplot(1,2,2); surf(PSF2); title('corresponding PSF');
%      axis square; axis tight
%       
% 参考： PSF2OTF, CIRCSHIFT, PADARRAY.



%   Copyright 1993-2002 The MathWorks, Inc.  
