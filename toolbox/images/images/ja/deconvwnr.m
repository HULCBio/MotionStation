% DECONVWNR  Wiener フィルタを使って、イメージの再構成 
% J = DECONVWNR(I,PSF) は、Wiener フィルタアルゴリズムを使って、イメージ
% I を分解し、明瞭化したイメージ J を出力します。イメージ I は、真のイメ
% ージと点像強度関数 PSF をコンボリューションし、ノイズを付加したものと考
% えます。アルゴリズムは、推定したイメージと真のイメージの間の差が、イメ
% ージやノイズの相関行列を利用して、最小二乗誤差の意味で最適化します。ノ
% イズが存在しない場合、Wiener フィルタは、理想的な逆フィルタになります。
%
% 再構成の質を改良するために、つぎの付加的なパラメータを渡すことができま
% す。
%   J = DECONVWNR(I,PSF,NSR)
%   J = DECONVWNR(I,PSF,NCORR,ICORR), ここで
%
% NSR は、ノイズと信号のパワーの比です。NSR は、スカラ、または、I と同じ
% サイズの配列で、デフォルトは0です。
%
% NCORR と ICORR は、ノイズ NCORR とオリジナルイメージ ICORR の自己相関関
% 数です。NCORR と ICORR は、オリジナルイメージより次元、サイズとも小さい
% ものです。N-次元の NCORR と ICORR 配列は、各次元の中の自己相関に対応し
% ます。ベクトル NCORR 、または、ICORR は、PSF がベクトルの場合、最初の次
% 元に自己相関関数を表わします。PSF が配列の場合、1次元自己相関関数は、PSF
% のすべてのシングルトンでない次元に対称性をもって、外挿されます。スカラ 
% NCORR、または、ICORR は、ノイズ、または、イメージのパワーを表わします。
%
% 出力イメージ J は、アルゴリズムの中で使われる離散フーリエ変換が起因する
% リンギングを指名していることに注意してください。DECONVWNR をコールする
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
%      noise = 0.1*randn(size(I));
%      PSF = fspecial('motion',21,11);
%      Blurred = imfilter(I,PSF,'circular');
%      BlurredNoisy = im2uint8(Blurred + noise);
%      
%      NSR = sum(noise(:).^2)/sum(I(:).^2);% ノイズとパワーの比
%      
%      NP = abs(fftn(noise)).^2;% ノイズのパワー
%      NPOW = sum(NP(:))/prod(size(noise));
%      NCORR = fftshift(real(ifftn(NP)));% ノイズの自己相関関数を計算し 
%                                        % 並び替え
%      IP = abs(fftn(I)).^2;% オリジナルイメージのパワー
%      IPOW = sum(IP(:))/prod(size(I));
%      ICORR = fftshift(real(ifftn(IP)));% イメージの自己相関を計算し、
%                                        % 並べ替え
%      ICORR1 = ICORR(:,ceil(size(I,1)/2));
%
%      NSR = NPOW/IPOW;% ノイズとパワーの比
%      
%      subplot(221);imshow(BlurredNoisy,[]);
%                     title('A = Blurred and Noisy');
%      subplot(222);imshow(deconvwnr(BlurredNoisy,PSF,NSR),[]);
%                     title('deconvwnr(A,PSF,NSR)');
%      subplot(223);imshow(deconvwnr(BlurredNoisy,PSF,NCORR,ICORR),[]);
%                     title('deconvwnr(A,PSF,NCORR,ICORR)');
%      subplot(224);imshow(deconvwnr(BlurredNoisy,PSF,NPOW,ICORR1),[]);
%                     title('deconvwnr(A,PSF,NPOW,ICORR_1_D)');
%
% 参考：DECONVREG, DECONVLUCY, DECONVBLIND, EDGETAPER, PADARRAY, 
%       PSF2OTF, OTF2PSF.



%   Copyright 1993-2002 The MathWorks, Inc.  
