% GLMVAL   一般化線形モデルに対するフィッティング値を計算
%
% YHAT=GLMVAL(BETA,X,LINK) は、リンク関数 LINK と 予測子 Xを使用した
% 一般化線形モデルに対してフィッティング値を計算します。BETA は、関数
% GLMFITにより出力される係数推定のベクトルです。LINK は、関数GLMFITで
% 使用できる要素構成からなる行列の型でも設定できます。
%
% [YHAT,DYLO,DYHI] = GLMVAL(BETA,X,LINK,STATS,CLEV) は、また、推測される
% Yの値についての信頼区間を計算します。STATS は、GLMFITにより出力される
% stats構造体です。DYLO とDYHI は、それぞれYHAT-DYLO の信頼区間の下界と、
% YHAT+DYHIの信頼区間の上界を定義します。CLEV は、(デフォルトでは、95%の
% 信頼区間に対して、0.95である)信頼レベルです。信頼限界は、非同期であり、
% それらは、フィッティングされた曲線に適用され、新しい観測には、適用され
% ません。
%
% [YHAT,DYLO,DYHI] = GLMVAL(BETA,X,LINK,STATS,CLEV,N,OFFSET,CONST) は、
% オプション引数を使って、追加のオプションを指定します。N は、GLMFIT と
% 共に使う分布が、二項分布の場合、二項分布のN の値になり、他の分布の場合、
% 空の配列になります。
% OFFSET は、GLMFITに、オフセット引数を提供する場合、オフセット値の
% ベクトルで、オフセットが使用されない場合、空の配列です。
% CONST は、fitが定数項を含む場合、'on'で、含まない場合、'off'です。
%
% 参考 : GLMFIT.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2003/02/12 17:12:12 $
