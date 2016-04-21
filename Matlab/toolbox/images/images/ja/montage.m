% MONTAGE   長方形のモンタージュとして、マルチイメージフレームを表示
%
% MONTAGE は、マルチフレームイメージ配列のフレームすべてを単一イメージ
% オブジェクトに、ほぼ正方形の型に配列して表示します。
%
% MONTAGE(I) は、強度イメージ配列 I の K 個のフレームを表示します。I は
% M x N x 1 x K です。
%
% MONTAGE(BW) は、バイナリイメージ配列 BW の K 個のフレームを表示しま
% す。BW は、M x N x 1 x K です。
%
% MONTAGE(X,MAP) は、インデックス付きイメージ配列 X の K 個のフレーム
% を、すべてのフレームに対してカラーマップ MAP を使って表示します。
% X は、M x N x 1 x K です。
%
% MONTAGE(RGB) は、トゥルーカラーイメージ配列 RGB の K 個のフレームを
% 表示します。RGB は、M x N x 3 x K です。
%
% H = MONTAGE(...) は、イメージオブジェクトのハンドル番号を出力します。
% 
%
% クラスサポート
% -------------
% 入力イメージは、logical、uint8、uint16、または、double のいずれの
% クラスもサポートしています。
%
% 例題
% ----
%       load mri
%       montage(D,map)
%
% 参考：IMMOVIE



%   Copyright 1993-2002 The MathWorks, Inc.  
