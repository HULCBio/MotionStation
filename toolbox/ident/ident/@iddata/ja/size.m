% SIZE は、IDDATA データセットのサイズを算出します。
%
%  [N,NY,NU,NE] = SIZE(DAT)
% 
% は、データ数(N)、出力チャンネル数(NY)、入力チャンネル数(NU)、実験数(NE)
% を出力します。マルチ実験に対して、N は各実験のデータを含む行ベクトルで
% す。
%
% SIZE(DAT) 自身でも情報を表示します。
%
%     N = SIZE(DAT,1)、または、N = SIZE(DAT,'N');
%     NY = SIZE(DAT,2)、または、NY = SIZE(DAT,'NY');
%     NU = SIZE(DAT,3)、または、NU = SIZE(DAT,'NU');
%     NE = SIZE(DAT,4)、または、NE = SIZE(DAT,'NE');
%
% Nn = SIZE(DAT) は、単実験では、Nn = [N, Ny, Nu] を、複数の実験では、Nn 
% = [sum(N),Ny,Nu,Ne] を出力します。



%   Copyright 1986-2001 The MathWorks, Inc.
