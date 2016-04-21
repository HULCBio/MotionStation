% GENTRESP   時間ベクトルを生成し、時間応答を計算
%
% 低水準ユーティリティ
%
% 1. Focus = [T(1), T(end)]  T がベクトルの場合
% 2. Focus = [0, T]          T がスカラの場合(終了時間)
% 3. Focus = [0, Tf]         計算された終了時間 Tf に対して T = [] の場合
% 2と3のケースに対して、実際のシミュレーション時間(出力ベクトル T)は、
% Focus(2) を超えます。


%  Author(s): B. Eryilmaz, P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc. 
