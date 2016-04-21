% IDFRD は、Identified Frequency Response Data モデルの作成、または、ID-
% FRDモデルへの変換を行ないます。
%
% Identified Frequency Response Data (IDFRD) モデルは、不確かさを含む線形
% システムの周波数応答を格納する場合に有効なものです。IDFRD は、実験的な
% 応答データや関数 SPA や ETFE から直接推定できる周波数応答も格納すること
% ができます。
%
% 注意：
%    MF = IDFRD(RESPONSE,FREQS,TS) 
% 
% は、FREQS で与えられる周波数点で、RESPONSE の中の応答データをもつ IDFRD
% モデル MF を作成します。TS = 0 を使って、連続時間システムからの応答も定
% 義します。詳細は、"データフォーマット"を参照してください。
%
% 応答の不確かさ(共分散)に関する情報を得るには、
% 
%    MF = IDFRD(RESPONSE,FREQS,TS,'CovarianceData',COVARIANCE)
% 
% を使います。ここで、COVARIANCE は、下に示す希望するフォーマットで、RE-
% SPONSE の共分散を含んでいます。
%
% 擾乱(ノイズ)のスペクトルに関する情報を含むため、または、時系列のスペク
% トルを格納するため、不確かさに関するプロパティ'SpectrumData'や'Noise-
% Covariance'を使います。
% 
%    MF = IDFRD(RESPONSE,FREQS,TS,'CovarianceData',COVARIANCE,...
%               'SpectrumData',SPECTRUM,'NoiseCovariance',COVSPECT)
% 
% データフォーマットについては、下のものを参照してください。
%
% IDFRD モデルは、任意の IDMODEL または、LTI モデル MOD を周波数応答デー
% タに変換することにより作成できます。
%
%    MF = IDFRD(MOD)、または、 MF = IDFRD(MOD,FREQS)
%
% 周波数応答や出力ノイズスペクトルは、それらの共分散と同様に、MOD から計
% 算され、MF に格納されます。MOD の内の任意の InputDelay が、位相遅れに変
% 換され、この場合、MF が InputDelay = zeros(nu,1) になります。
%
% 上のすべてのシンタックスにおいて、入力リストは、IDFRD モデルの種々のプ
% ロパティを設定するために、
% 
%       'PropertyName1', PropertyValue1, ...
% 
% のようにペアで設定します(詳細は、IDPROPS IDFRD と入力してください)。
%
% データフォーマット：
% SISO モデルに対して、FREQS は、実数周波数ベクトルで、RESPONSE は、応答
% データベクトルで、ここで、RESPONSE(i) は、FREQS(i) でシステム応答を表わ
% します。
%
% NY 出力、NU 入力をもち、周波数点 NF 個をもつMIMO IDFRD モデルに対して、
% RESPONSE は、NY-NU-NF 配列になります。ここで、RESPONSE(i,j,k) は、入力 
% j から出力 i への周波数 FREQS(k) での周波数応答を設定します。
%
% COVARIANCE は、5D 配列で、COVARIANCE(KY,KU,k,:,:))は、RESPONSE(KY,KU,k)
% の2行2列の共分散行列です。(1,1)要素は、実数部の分散、(2,2)要素が虚数部
% の分散、(1,2)と(2,1)要素は、実数と虚数部間の共分散です。SQUEEZE(COVAR-
% IANCE(KY,KU,k,:,:)) は、対応する応答の共分散行列を与えます。
%
% SPECTRUM は、NY-NY-NF 配列で、SPECTRUM(ky1,ky2,k) は、周波数 FREQS(k) 
% で、出力ky1 と出力 ky2 での擾乱間のクロススペクトルです。
%
% COVSPECT は、SOECTRUM と同じ次元の配列です。ここで、COVSPECT(ky1,ky2,k)
% は、SPECTRUM(k1,k2,k) の分散になります。
%
% デフォルトで、FREQS の中の周波数の単位は、'rad/sec'です。また、'Units' 
% プロパティを使って、'Hz' に変更することができます。このプロパティ値を変
% 更することは、数値的な周波数値を変更することではないことを注意してくだ
% さい。CHGUNITS(SYS,UNITS) を使って、FRD モデルの周波数単位を変更し、必
% 要なら変換もします。
% 



%   Copyright 1986-2001 The MathWorks, Inc.
