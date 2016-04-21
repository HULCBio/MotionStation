% BANDWIDTH   周波数応答のバンド幅を計算
% 
% FB = BANDWIDTH(SYS) は、SISOモデル SYS のバンド幅 FB を出力します。
% FB は、その周波数で、ゲインは、DC値の70.79% (-3 dB) 以下に減衰する
% 最初の周波数として定義されます。周波数FBは、ラジアン/秒で表されます。  
% TF, SS, あるいは、ZPK を使用して、SYS を作成することができます。
% 詳細は、LTIMODELSを参照してください。
%
% FB = BANDWIDTH(SYS,DBDROP) は、さらに、限界のゲイン減衰をdB単位で指定
% します。デフォルトの値は、-3 dB、すなわち、70.79% に減衰する値です。
%
% SYS が、LTIモデルのS1×...×Sp 配列である場合、BANDWIDTH は、つぎの
% ようにして、同じサイズの配列を出力します。
%
%      FB(j1,...,jp) = BANDWIDTH(SYS(:,:,j1,...,jp)) .  
%
% 参考 : DCGAIN, ISSISO, LTIMODELS.


%   Author(s): P. Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
