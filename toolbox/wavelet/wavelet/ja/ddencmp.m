% DDENCMP　 雑音除去または圧縮処理に関連したデフォルト値の算出
% [THR,SORH,KEEPAPP,CRIT] = DDENCMP(IN1,IN2,X) は、ウェーブレットまたはウェーブ
% レットパケットを使って、1次元の入力ベクトル信号または2次元の入力行列信号の雑音
% 除去または圧縮に対するデフォルト値を出力します。THR はスレッシュホールド値、
% SORH はソフトスレッシュホールドまたはハードスレッシュホールドの指標、KEEPAPP 
% は Approximation 係数を処理するかどうかの設定、CRIT (ウェーブレットパケットに
% 対してのみ用いられます)は、使用するエントロピーの名前(WENTROPY を参照)です。引
% 数 IN1 は、'den' または'cmp' です。そして、引数 IN2 は、'wv' または 'wp' です。
%
% ウェーブレットに対しては、出力引数は3つです。[THR,SORH,KEEPAPP] = DDENCMP...
% (IN1,'wv',X) は、IN1 = 'den' のときは、X の雑音除去、IN1 = 'cmp' のときは、X 
% の圧縮として、それぞれ関連するデフォルト値を出力します。これらの値は、関数 W-
% DENCMP で用いられます。
%
% ウェーブレットパケットに対しては、出力引数は4つです。[THR,SORH,KEEPAPP,CRIT] =
% DDENCMP(IN1,'wp',X) は、IN1 = 'den' のときは、X の雑音除去、IN1 = 'cmp' のとき
% は、Xの圧縮として、それぞれ関連するデフォルト値を出力します。これらの値は、関
% 数 WPDENCMP で用いられます。
%
% 参考： WDENCMP, WENTROPY, WPDENCMP.



%   Copyright 1995-2002 The MathWorks, Inc.
