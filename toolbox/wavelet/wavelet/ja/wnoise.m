% WNOISE　 雑音を含んだウェーブレットテストデータを作成
% X = WNOISE(FUN,N) は、[0,1] の範囲の 2^N サンプル上で、FUN によるテスト関数の
% 値を出力します。
%
% [X,XN] = WNOISE(FUN,N,SNRAT) は、上述のようにテストベクトル X を出力し、標準偏
% 差 std(x) = SNRAT となるように再スケーリングします。出力されたベクトル XN は、
% ベクトルの値 X に、加算的なガウス白色雑音 N(0,1) が重ねられたものです。XN は、
% 信号と雑音の比が SNRAT です。
%
% [X,XN] = WNOISE(FUN,N,SNRAT,INIT) は、ベクトル X と XN を出力しますが、生成の
% ための乱数シードとして INIT が用いられます。
%
% つぎの6個の関数が、Donoho と Johnstone により"Adapting to unknown smoothness 
% via wavelet shrinkage"  Preprint Stanford、january 93、p 27-28.において紹介さ
% れています。
%   FUN = 1 または FUN = 'blocks'     
%   FUN = 2 または FUN = 'bumps'      
%   FUN = 3 または FUN = 'heavy sine'   
%   FUN = 4 または FUN = 'doppler'   
%   FUN = 5 または FUN = 'quadchirp'   
%   FUN = 6 または FUN = 'mishmash'     
% 



%   Copyright 1995-2002 The MathWorks, Inc.
