% SPA は、スペクトル解析を行います。
% 
%   G = SPA(DATA)  
%
%   DATA : IDDATA オブジェクトの型で表した出力 - 入力データ(HELP IDDATA
%          を参照)
%   G    : IDFRD オブジェクトの型で表した周波数応答と不確かさを出力
%          モデル y = G u + v のノイズ v のスペクトルも含まれています。
%          help IDFRD を参照してください。
%
% DATA が時系列の場合、G は、推定したスペクトルと推定した不確かさと共に
% 出力されます。
%
% スペクトルは、ラグサイズ min(length(DATA)/10,30) をもつ Hamming ウイン
% ドウを利用して計算されます。G = SPA(DATA,M) と実行することで、ラグサイ
% ズを M に変更することができます。
% 
% 関数は、0からπまでの間を128等分に分割して計算されます。関数は、G = SPA
% (DATA,M,w) を使って、(関数 LOGSPACE で作成した)任意の周波数 w で計算す
% ることもできます。
%    
% G = SPA(DATA,M,w,maxsize) を使って、メモリとスピードのトレードオフを行
% います。IDPROPS ALGORITHM を参照してください。
%
% データに測定入力が含まれる場合、
% 
%   [Gtf,Gnoi,Gio] = SPA(DATA, ... )
% 
% は、3つの異なる IDFRD モデルの情報を出力します。
% 
% Gtf は、入力から出力までの伝達関数の推定を含んでいます。
% Gnoi は、出力分布 v のスペクトルを含んでいます。
% Gio は、出力チャンネル、入力チャンネルの組み合わせによるスペクトル行列
% を含んでいます。
%
% 参考： IDMODEL/BODE, IDMODEL/NYQUIST, ETFE, IDFRD

%   L. Ljung 10-1-86, 29-3-92 (mv-case),11-11-94 (complex data case)


%   Copyright 1986-2001 The MathWorks, Inc.
