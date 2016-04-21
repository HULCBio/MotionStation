% GENPARAM ANFIS 学習用の初期メンバシップ関数パラメータの作成
% 
% GENPARAM(DATA,MF_N,MF_TYPE) は、M 行 N 列の訓練データ行列 DATA から初
% 期入力 MF パラメータを作成します。ここで、M は訓練データペアの数、N は
% 入力数に1を加えたものです。
% 
% MF_N と MF_TYPE は、各入力の MF 数と MF タイプをそれぞれ設定するオプシ
% ョンの引数です。MF_N は、長さ N のベクトルでなければなりません。MF_N 
% がスカラである場合、それをすべての入力へ適用します。同様に、MF_TYPE は
% N 行の文字列行列でなければなりません。MF_TYPE が単一の文字列の場合、そ
% れをすべての入力へ適用します。MF_N と MF_TYPE のデフォルト値は、それぞ
% れ、2と 'gbellmf' です。
%
% 作成された MF の中心は、常に入力変数の領域沿いに等間隔で区切られます。
% ここで、領域を DATA の対応する列の min と max 間の間隔として決定してい
% ます。
%
% 制限事項
% (1) 'sigmf'、'smf'、'zmf'のMFタイプは、左側または右側のどちらかが開い
%     た型になっているのでサポートされていません。
% (2) 同一 MF タイプは、同じ入力変数の MF へ割り当てられます。
%
% 例題
%    NumData = 1000;
%    data = [rand(NumData,1) 10*rand(NumData,1)-5 rand(NumData,1)];
%    NumMf = [3 7];
%    MfType = str2mat('trapmf','gbellmf');
%    MfParams = genparam(data,NumMf,MfType);
%    set(gcf,'Name','genparam','NumberTitle','off');
%    NumInput = size(data,2) - 1;
%    range = [min(data)' max(data)'];
%    FirstIndex = [0 cumsum(NumMf)];
%    for i = 1:NumInput;
%       subplot(NumInput,1,i);
%       x = linspace(range(i,1),range(i,2),100);
%       index = FirstIndex(i)+1:FirstIndex(i)+NumMf(i);
%       mf = evalmmf(x,MfParams(index,:),MfType(i,:));
%       plot(x,mf');
%       xlabel(['input ' num2str(i) ' (' MfType(i,:) ')']);
%    end
%
% 参考    GENFIS1, ANFIS.



%   Copyright 1994-2002 The MathWorks, Inc. 
