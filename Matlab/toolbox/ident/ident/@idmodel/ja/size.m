% SIZE  は、モデルのサイズを計算する関数です。
% 
%   [Ny,Nu,Npar] = SIZE(Mod)
%   [Ny,Nu,Npar,Nx] = SIZE(Mod) 
%
% Ny は、IDMODEL Mod の出力チャンネル数です。
% Nu は、入力チャンネル数です。
% Npar は、Mod の中のパラメータで、自由パラメータ(推定パラメータ)の数で
%    す。
% Nx は、状態数です。これは、状態空間モデル(IDSS と IDGREY)に対してのみ
%    出力されます。 
%
% サイズの要素の一つのみにアクセスするには、Ny = size(Mod,1), Nu = size
% (Mod,2), Npar = size(Mod,3), Nx = size(Mod,4), Ny = size(Mod,'Ny'), Nu
% = size(Mod,'Nu') 等を使います。
%
% 1つのみの出力引数をもつ場合、N = SIZE(Mod) は、N = [Ny Nu Npar] を出力
% します。
%
% 出力引数を設定しない場合、これらの情報がMATLAB コマンドウインドウに表
% 示されます。



%   Copyright 1986-2001 The MathWorks, Inc.
