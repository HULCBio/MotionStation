% REGSTATS   線形モデルに対する回帰診断
%
% REGSTATS(RESPONSES,DATA,MODEL) は、行列 DATA の値に対して、ベクトル 
% RESPONSESで設定された次数で、回帰近似を行います。関数は、ユーザインタ
% フェースを作成し、チェックボックス群に診断統計量を表示し、指定した変
% 数名でベースワークスペースにセーブします。MODEL は、回帰モデルの次数
% をコントロールします。デフォルトでは、REGSTATS は、 定数項をもつ線形
% 加算モデルに対する設計行列を出力します。
%
% MODEL には、つぎの文字列を使用することができます。
%   'linear'        - 定数、線形項を含む
%   'interaction'   - 定数、線形項、クロス積の項を含む
%   'quadratic'     - 相互作用に二乗項を追加
%   'purequadratic' - 定数、線形項、二乗項を含む
%
% 係数の順番は、関数 X2FXにより定義される順番です。
%
% STATS=REGSTATS(RESPONSES,DATA,MODEL,WHICHSTATS)は、WHICHSTATSに
% リストされた統計量を含む出力構造体STATSを作成します。
% WHICHSTATSは、'leverage'のような単一の名前、あるいは、
% {'leverage' 'standres' 'studres'}のような名前のセル配列のいずれか
% になります。使用可能な名前は、つぎのようになります。
%
%      名前          意味
%      'Q'           XのQR 分解からのQ
%      'R'           XのQR 分解からのR
%      'beta'        回帰係数
%      'covb'        回帰係数の共分散
%      'yhat'        応答データのフィッテングした値
%      'r'           残差
%      'mse'         平均二乗誤差
%      'leverage'    Leverage
%      'hatmat'      Hat (射影) 行列
%      's2_i'        Delete-1 分散
%      'beta_i'      Delete-1 係数
%      'standres'    標準化された残差
%      'studres'     スチューデント化された残差
%      'dfbetas'     回帰係数のスケールされた変化
%      'dffit'       フィッテングされた値における変化
%      'dffits'      フィッテングされた値におけるスケールされた変化
%      'covratio'    共分散の変化
%      'cookd'       Cookの距離
%      'tstat'       係数に対するt統計量
%      'fstat'       F統計量
%      'all'         上記の統計量をすべて生成する
%
% 例題:  Haldデータに対する残差とフィットした値をプロットします。
%      load hald
%      s = regstats(heat,ingredients,'linear',{'yhat','r'});
%      scatter(s.yhat,s.r)
%      xlabel('Fitted Values'); ylabel('Residuals');
%
% 参考 : LEVERAGE, STEPWISE, REGRESS.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:06:54 $ 
