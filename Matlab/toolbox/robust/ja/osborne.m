% OSBORNE   Osborne法を使って、対角化スケーリング
%
% [MU,ASCALED,LOGD] = OSBORNE(A)
% [MU,ASCALED,LOGD] = OSBORNE(A,K) 
% この関数は、つぎの式によって計算される構造化特異値(ssv)のスカラ上界MUを
% 出力します。
% 
%           mu = max(svd(diag(dosb)*A/diag(dosb)))
% 
% ここで、dosbは、Osborneスケーリング法を適用して得られます。
%
% 入力:
%     A  -- ssvが計算されるp行q列複素行列。
% 
% オプション入力:
%     K  -- n行1列、または、n行2列行列で、その行はssvが評価される不確かさ
%           ブロックのサイズです。Kは、sum(K) == [q,p]を満足しなければなり
%           ません。
%           Kの1番目の列のみが与えられた場合は、不確かさブロックは、
%           K(:,2)=K(:,1)のように正方になります。
% 出力:
%     MU      -- Aの構造化特異値の上界。
%     ASCALED -- diag(dosb)*A/diag(dosb)
%     LOGD    -- dosb=exp(LOGD))は、Osborneスケーリングベクトルです。
%



% Copyright 1988-2002 The MathWorks, Inc. 
