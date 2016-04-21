% FITD は、設定した Bode 線図の状態空間実現を行ないます。
%
% [SS_D,LOGDFIT] = FITD(LOGD,W,N,BLKSZ,FLAG)
% [AD,BD,CD,DD,LOGDFIT] = FITD(LOGD,W,N,BLKSZ,FLAG) は、行列 LOGD の行で
% 与えられた Bode 線図のゲインデータに近似的に適合する対角伝達関数行列の
% 安定な最小位相状態空間実現 SS_D を出力します。数値的に安定なルーチン 
% "YLWK.M"を使います。
%
%   入力:        LOGD  行列の行は、Bode線図のゲインプロットのログです。
%                W は、周波数ベクトルです。
%   オプション: N は、近似に使用する希望する次数を表すベクトル
%               (デフォルト = 0);
%               BLKSZ は、SS_D の中の対角行列のサイズを示すベクトル
%               (デフォルト = 1);
%                FLAG (デフォルト：Bode 線図の表示; 0: Bode 線図を表示し
%                ません);
%       ?????? Bode plot of the fit will be displayed 4 at a time
%              with a "pause" in between every full screen display.
% 
%   出力:      SS_D は、対角伝達関数行列 D(s) =diag(d1(s)I1,...,dn(s)In)
%              の状態空間実現です。ここで、di(s) は、LOGD の i 番目の行
%              への近似で、I1,...In は、n ベクトル BLKSZ の中で要素とし
%              て与えられる大きさをもつ単位行列です。
%              LOGDFIT は、LOGD、すなわち、SS_D の Bode 線図への近似を含
%              んでいます。

% Copyright 1988-2002 The MathWorks, Inc. 
