% IMNOISE   イメージにノイズを付加
%   J = IMNOISE(I,TYPE,...) は、強度イメージ I に TYPE で設定したノイ
%   ズを付加します。TYPE には、つぎのいずれかを設定することができま
%   す。
%
%       'gaussian'       一様の平均と分散をもつガウス白色ノイズ
%                        mean and variance
%
%       'localvar'       強度に依存した分散をもつ平均がゼロの Gaussian 
%                        白色ノイズ
%
%       'poisson'        Poisson noise
%
%       'salt & pepper'  ピクセルの on と off の混在したノイズ
%
%       'speckle'        累積的なノイズ
%
%   TYPE に基づいて、IMNOISE に追加のパラメータを設定することができます。
%   すべての数値パラメータは正規化されています。これらは、0 から 1 の強
%   度の範囲をもつイメージへの演算に対応したものです。
%   
%   J = IMNOISE(I,'gaussian',M,V) は、イメージ I に平均値 M、分散 V の
%   ガウス白色ノイズを付加します。デフォルト値は、V は0.01で、M は0で
%   す。
%   
% J = imnoise(I,'localvar',V) は、イメージ I に、平均値0、局所的なガウ
% ス白色ノイズ V を加えます。V は、I と同じサイズの配列です。
%
% J = imnoise(I,'localvar',IMAGE_INTENSITY,VAR) は、イメージ I にゼロ平
% 均、ガウスノイズを加えます。ここで、ノイズのローカル分散は、I のイメ
% ージの強度値の関数です。IMAGE_INTENSITY と VAR は、同じサイズのベクト
% ルで、PLOT(IMAGE_INTENSITY,VAR) は、ノイズの分散とイメージ強度の関数
% 関係をプロット表示します。
% IMAGE_INTENSITY は、0と1の範囲の正規化された強度値です。
%
% J = IMNOISE(I,'poisson') は、データに人工的なノイズを加えるのではなく、
% データから Poisson ノイズを作成します。Poisson 統計量については、uint8 
% や uint16 のイメージの強度は、フォトンの数に対応しているとします。
% 倍精度のイメージは、ピクセルあたりのフォトンの数65535 より多い場合に使
% われます。すなわち、強度値は、0 と 1 の間で変化する強度値で、10^12 で除
% 算したフォトンの数に対応します。
%
% J = IMNOISE(I,'salt & pepper',D) は、イメージIに胡麻塩ノイズを付加しま
% す。ここで、D はノイズ密度です。これは、近似的に、D*PROD(SIZE(I)) ピク
% セルに影響を与えます。デフォルト値は、0.05ノイズ密度です。
%   
% J = IMNOISE(I,'speckle',V) は、イメージ I に累積ノイズを付加します。こ
% こでは、式 J = I+n*I を使います。ここで、n は、平均が0、分散が V の一
% 様分布乱数です。V に対するデフォルトは0.04です。
%   
% クラスサポート
% -------------
% 入力イメージ I は、uint8、uint16、または、double のいずれのクラス
% もサポートしています。出力イメージ J は、I と同じクラスになりま
% す。 I が、2次元以上の場合、多次元強度イメージとして取り扱いますが、
% RGB イメージのようには、扱いません。
%
% 例題
% ----
%        I = imread('eight.tif');
%        J = imnoise(I,'salt & pepper', 0.02);
%        imshow(I), figure, imshow(J)
%
% 参考：IMNSTATS, RAND, RANDN



%   Copyright 1993-2002 The MathWorks, Inc.  
