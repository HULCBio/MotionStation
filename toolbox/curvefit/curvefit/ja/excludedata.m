% EXCLUDEDATA   削除されるデータのマーク付け
% OUTLIERS = EXCLUDEDATA(XDATA,YDATA,'METHOD',VALUE) は、XDATA と YDATA 
% と同じ大きさをもつ論理ベクトルで、要素1は、無視する点、0は削除しない点
% を表わします。マークされる点は、文字列'METHOD'と関連した VALUE  に依存
% します。
% 
% METHOD と VALUE に対して、つぎのものの中から選択できます。
%
%   Indices - 異常値としてマークした個々の点のインデックスを要素とした
%             ベクトル
%   Domain  - [XMIN XMAX] この範囲外を異常値としてマークする範囲を指定
%             する値
%   Range   - [YMIN YMAX] このレンジ外を異常値としてマークするレンジを
%             指定する値
%   Box     - [XMIN XMAX YMIN YMAX] この範囲外を異常値としてマークする
%             ボックスを指定する座標
%
% これらを組み合わせるには、| (or) 演算子を使います。  
%
% 例題：
%    outliers = excludedata(xdata, ydata, 'indices', [3 5]);
%    outliers = outliers | excludedata(xdata, ydata, 'domain', [2 6]);
%    fit1 = fit(xdata,ydata,fittype,'Exclude',outliers);
%
% いくつかの場合、すべてのデータを保持するために、これらすべてを含むボッ
% クスを指定したい場合があります。EXCLUDEDATA を使って、これを行うには、
% NOT (~) を使います。
%
%    outliers = ~excludedata(xdata,ydata,'box',[2 6 2 6])
%
% 参考   FIT

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
