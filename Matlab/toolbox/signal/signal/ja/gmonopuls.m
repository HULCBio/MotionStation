% GMONOPULS は、Gaussian モノパルス発生器です。
% Y = GMONOPULS(T,FC) は、配列 T で示される時間で、中心周波数 FC(Hz)
% をもつ 単位振幅をもつGaussian モノパルスサンプルを出力します。
% デフォルトは、FC = 1000 Hz です。
%
% TC = GMONOPULS('cutoff',FC) は、パスルの最大振幅と最小振幅の時間
% 間隔を出力します。
%
% デフォルト値は、空または、省略することにより、使用できます
%
% 例題1：100 GHz のレートでサンプルされた2 GHz Gaussian モノパルスを
% プロットしましょう。
%       fc = 2E9;  fs=100E9;
%       tc = gmonopuls('cutoff', fc);
%       t  = -2*tc : 1/fs : 2*tc;
%       y = gmonopuls(t,fc); plot(t,y)
%
% 例題2：例題1を使って、7.5 nS の間隔で、モノパルス列を作成しましょう。
%      fc = 2E9;  fs=100E9;           % 中心周波数、サンプル周波数
%      D = [2.5 10 17.5]' * 1e-9;     % パルス遅れ時間
%      tc = gmonopuls('cutoff', fc);  % 各パルス間の幅
%      t  = 0 : 1/fs : 150*tc;        % 信号を計算する時間
%      yp = pulstran(t,D,@gmonopuls,fc);
%      plot(t,yp)
%
% 参考： GAUSPULS, TRIPULS, PULSTRAN, CHIRP.



%   Copyright 1988-2002 The MathWorks, Inc.
