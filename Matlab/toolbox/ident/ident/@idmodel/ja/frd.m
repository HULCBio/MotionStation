% FRD は、モデルオブジェクトを LTI/FRD オブジェクトに変換します。
% Control System Toolbox を必要とします。
% 
%   SYS = FRD(MF)
%
% MF は、IDFRD モデルで、SPA, ETFE, IDFRD で例として定義されています。
%   
% MF が、IDMODEL オブジェクトの場合、まず、IDFRD に変換します。そして、
% シンタックス  
% 
%   SYS = FRD(MF,W)
% 
% は、周波数ベクトル W を指定することができます。W を省略すると、デフォ
% ルト選択が行われます。
%
% SYS は、FRD オブジェクトとして出力されます。
%
% 共分散情報やスペクトル情報は、変換されません。



%   Copyright 1986-2001 The MathWorks, Inc.
