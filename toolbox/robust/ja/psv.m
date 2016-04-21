% PSV   Perron固有値法による対角のスケーリング
%
% [MU,ASCALED,LOGD] = PSV(A)
% [MU,ASCALED,LOGD] = PSV(A,K) 
% この関数は、つぎの式によって計算される構造化特異値(ssv)のスカラ上界MUを
% 計算します。
%           mu = max(svd(diag(dperron)*A/diag(dperron)))
% ここで、dperronは、SafonovのPerron固有ベクトルスケーリング法
% (IEE Proc., Pt. D, Nov. '82)を行列Aに適用して得られます。
%
% 入力:
%     A  -- ssvが計算されるp行q列複素行列。
% 
% オプション入力:
%     K  -- n行1列またはn行2列行列で、その行はssvが評価される不確かさ
%           ブロックサイズです。Kは、sum(K) == [q,p]を満足しなければ
%           なりません。Kの1番目の列のみが与えられた場合は、不確かさ
%           ブロックは、K(:,2)=K(:,1)のように正方になります。
% 
% 出力:
%     MU      -- Aの構造化特異値の上界。
%     ASCALED -- diag(dperron)*A/diag(dperron)
%     LOGD    -- dperron=exp(LOGD))は、perronスケーリングベクトルです。
%



% Copyright 1988-2002 The MathWorks, Inc. 
