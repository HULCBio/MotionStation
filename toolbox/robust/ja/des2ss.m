% DES2SS   ディスクリプタ状態空間型を通常の状態空間型に変換
%
% [SS_D] = DES2SS(SS_DES,K)、または、[AD,BD,CD,DD] = DES2SS(A,B,C,D,E,K)
% は、ディスクリプタEの特異値分解を使って、ディスクリプタ型のシステムを
% 通常の状態空間型に変換します。
%
%  入力データ          : ss_des = mksys(a,b,c,d,e,'des');
%  オプション入力データ: k = Eのヌル空間の次元
%  出力データ          : ss_d  = mksys(a,b,c,d);



% Copyright 1988-2002 The MathWorks, Inc. 
