% FRD は、モデルオブジェクトを LTI/FRD オブジェクトに変換します。Control 
% System Toolbox が必要です。
% 
%   SYS = FRD(MF)
%
% MF は、SPA, ETFE, IDFRD で得られる IDFRD モデルです。
%   
% MF が IDMODEL オブジェクトの場合、まず、IDFRD に変換します。その後、つ
% ぎのシンタックス 
% 
%   SYS = FRD(MF,W)
% 
% を使って、周波数ベクトル W を指定することができます。W を省略すると、デ
% フォルトの選択が使われます。
%
% SYS は、FRD オブジェクトとして出力されます。
%
% 共分散情報やスペクトル情報は、変換されません。



%   Copyright 1986-2001 The MathWorks, Inc.
