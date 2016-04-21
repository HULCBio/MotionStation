% WPDEC2 　2次元ウェーブレットパケット分解
% [T,D] = WPDEC2(X,N,'wname',E,P) は、'wname' により設定された(WFILTERS 参照)特
% 定のウェーブレットを用いたレベル N での行列 X のウェーブレットパケット再構成に
% 対応するツリー構造 T とデータ構造 D (MAKETREE参照)を出力します。
% 
% E は、エントロピーのタイプを示す文字列です(WENTROPY 参照)。
% E = 'shannon'、'threshold'、'norm'、'log energy'、'sure'、'user'
% P は、オプションパラメータです。
% E の値が、
%  'shannon'、または、'log energy' のときは、P は用いられません。
%  'threshold'、または、'sure' のときは、P はスレッシュホールド値です(0 < =  P)。
%  'norm' のときは、P はべき数です(1 < =  P < 2)。
%  'user' のときは、P はユーザが定義した関数の名前を示す文字列です。
%
% [T,D] = WPDEC2(X,N,'wname') は、[T,D] = WPDEC2(X,N,'wname','shannon') と等価で
% す。
%
% 参考： MAKETREE, WAVEINFO, WDATAMGR,  WENTROPY
%        WPDEC, WTREEMGR.



%   Copyright 1995-2002 The MathWorks, Inc.
