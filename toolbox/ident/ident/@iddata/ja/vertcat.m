% VERTCAT は、IDDATA モデルの垂直方向の連結を行います。
%
% DAT = VERTCAT(DAT1,DAT2,..,DATn)、または、DAT = [DAT1;DAT2;...;DATn] 
% は、DATkの入力サンプルと出力サンプルをそれぞれ組み合わせることで、デー
% タセットDATを作成します。したがって、各々の実験は同じチャンネル数となり、
% 各チャンネルのデータ数が多くなります。
%
% サブリファレンス手法を使って、データの一部を取り出します。
%    
%   DAT = DAT(1:300);
% 
% チャンネル名は、各々のDATkで同じでなければなりません。又、実験名も必要
% です。
% 
% 参考： IDDATA/SUBSREF, IDDATA/HORZCAT, IDDATA/SUBSASGN



%   Copyright 1986-2001 The MathWorks, Inc.
