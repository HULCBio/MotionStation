%function dsys = tustin(csys,T,prewarpf);
%
% prewarped Tustin変換を使って、連続SYSTEM行列(CSYS)から離散時間(DSYS)へ
% の変換を行います。Tは、サンプル時間(単位は秒)で、PREWARPはprewarp周波
% 数(ラジアン/秒)です。prewarp周波数を指定しなければ、標準の双一次変換が
% 行われます。
%
% 参考: DTRSP, SAMHLD.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
