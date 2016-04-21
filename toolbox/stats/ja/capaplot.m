% CAPAPLOT   工程能力プロット
%
% CAPAPLOT(DATA,SPECS) は、ベクトル DATA の観測値が、未知の平均値と分散を
% もつ正規分布に近似して、その結果の新しい観測分布をプロットします。2要素
% ベクトル SPECS で設定される分布の上限と下限の間の部分は、プロット図では、
% 影が付けられます。
% 
% [P, H] = CAPAPLOT(DATA,SPECS) は、仕様の範囲に存在する新しい観測の
% 確率 P とプロット要素のハンドル番号 H を出力します。


%   B.A. Jones 2-14-95
%   Copyright 1993-2002 The MathWorks, Inc. 
% $Revision: 1.6 $  $Date: 2003/02/12 17:10:41 $
