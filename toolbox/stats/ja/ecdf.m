% ECDF   経験累積分布関数(Kaplan-Meier)
%
% [F,X] = ECDF(Y) は、経験的な cdf としても知られる、累積分布関数(cdf)の
% Kaplan-Meier 推定を計算します。Y は、データ値のベクトルです。F は、
% X において求めた経験的な cdf 値のベクトルです。
%
% [F,X,FLO,FUP] = ECDF(Y) は、cdf に対する信頼下限および上限も出力します。
% これらの範囲は、Greenwood の公式を使って計算され、同時信頼区間では
% ありません。
%
% [...] = ECDF(Y,'PARAM1',VALUE1,'PARAM2',VALUE2,...) は、以下から選択
% された 名前/値 の組み合わせで付加的なパラメータを指定します。
%
%      名前          値
%      'censoring'   正確に観測された観測値に対して0を、右側打ち切りの
%                    観測値に対して1となる、X と同じ大きさの論理ベクトル
%                    です。デフォルトでは、全ての観測値が最後まで観測
%                    されます。
%      'frequency'   非負の整数カウントが含まれる X と同じ大きさのベク
%                    トルです。このベクトルのj番目の要素は、X のj番目の
%                    要素が観測された回数を示します。デフォルトはXの
%                    要素ごとの観測値に対して1です。
%      'alpha'       100*(1-alpha)% の信頼レベルに対する0から1の間の値
%                    です。デフォルトは 95% の信頼を表す alpha=0.05 に
%                    なります。
%      'function'    'cdf' (デフォルト)、'survivor'、または 'cumulative 
%                    hazard' から選択された、出力引数 F として返される
%                    関数のタイプです。
%
% 例題: ランダムな故障回数と、ランダムな打ち切り回数を生成し、既知で
% ある真の cdf を用いて、経験的な cdf と比較します。
%
%       y = exprnd(10,50,1);     % ランダムな故障回数 exponential(10)
%       d = exprnd(20,50,1);     % ドロップアウトした回数 exponential(20)
%       t = min(y,d);            % これらの回数の最小値を観測
%       censored = (y>d);        % 対象が失敗したかどうかを観測
%
%       % 経験的な cdf と信頼区間を計算し表示します。
%       [f,x,flo,fup] = ecdf(t,'censoring',censored);
%       stairs(x,f);
%       hold on;
%       stairs(x,flo,'r:'); stairs(x,fup,'r:');
%
%       % 既知である真の cdf のプロットを重ね描きします。
%       xx = 0:.1:max(t); yy = 1-exp(-xx/10); plot(xx,yy,'g-')   
%       hold off;
%
% 参考 : CDFPLOT.


% Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2002/11/26 19:56:09 $

