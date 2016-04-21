% FNMIN   (与えられた区間での)関数の最小値
%
% FNMIN(F) は、基本区間上で、F のスカラ値一変数スプラインの最小値を
% 出力します。 
%
% FNMIN(F,INTERV) は、INTERV により([a,b] として)指定される区間の最小値
% を出力します。 
%
% [MINVAL, MINSITE] = FNMIN(F ...) は、F にある関数が最小値 MINVAL を取る
% サイト MINSITE も与えます。
%
% 例題:
% spmak(1:5,-1) は、 節点列 (1,2,3,4,5) をもつ、キュービックB-スプライン
% の負の値を与えるため、以下のように、
%
%      [y,x] = fnmin(spmak(1:5,-1))
%   
% が、-2/3に等しい y と、3に等しい x を返すことを要求します。さらに、
% 
%      f = spmak(1:21,rand(1,15)-.5);
%      maxval = -fnmin(fncmb(f,-1))
%
% により、基本区間での f のスプラインの最大値を与えます。
%      
%      fnplt(f), hold on, plot(fnbrk(f,'in'),[maxval maxval]), hold off
%
% 参考 : FNZEROS, FNVAL.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc. 
