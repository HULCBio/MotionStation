% 2つのガウス曲線を合わせたメンバシップ関数
%
% 表示
%    y = gauss2mf(x,params)
%    y = gauss2mf(x,[sig1 c1 sig2 c2])
%
% 詳細
% ガウス関数は、2つのパラメータ sig と c を変数として、つぎのように表現
% されます。
% 
%    EXP(-(X - C).^2/(2*SIGMA^2));
% 
% 関数 gauss2mf は、2つのガウス関数を組み合わせています。最初の関数は、
% sig1 と c1 で設定され、左側の曲線を定義します。2番目の関数は、右側の曲
% 線を設定します。c1 < c2 のときは、いつでも、関数 gauss2mf は最大値1に
% 達します。他の場合、最大値は1未満です。パラメータは、つぎの順番で設定
% されます。
% 
%    [sig1,c1,sig2,c2]
%
% 例題
%    x = (0:0.1:10)';
%    y1 = gauss2mf(x,[2 4 1 8]);
%    y2 = gauss2mf(x,[2 5 1 7]);
%    y3 = gauss2mf(x,[2 6 1 6]);
%    y4 = gauss2mf(x,[2 7 1 5]);
%    y5 = gauss2mf(x,[2 8 1 4]);
%    plot(x,[y1 y2 y3 y4 y5]);
%    set(gcf,'name','gauss2mf','numbertitle','off');
%
% 参考    DSIGMF, EVALMF, GAUSSMF, GBELLMF, MF2MF, PIMF, PSIGMF, 
%         SIGMF, SMF, TRAPMF, TRIMF, ZMF.



%   Copyright 1994-2002 The MathWorks, Inc. 
