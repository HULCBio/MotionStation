% [a,b,c,d,e]=ltiss(sys)
%
% LTIシステムのSYSTEM行列表現SYSから状態空間行列A,B,C,D,Eを抜き出します。
%                                        -1
%                G(s)  =  D + C (s E - A)  B
%
% ワーニング:  出力引数Eが省略された場合、LTISSはG(s)の実現(E\A, E\B, C,
%              D)を出力します。
%
%  入力
%    SYS       LTISYSによって作成したSYSTEM行列
%
%  出力
%    A,B,C,D,E  SYSの状態空間行列
%
% 参考：  LTISYS, LTITF, SINFO.



%  Copyright 1995-2002 The MathWorks, Inc. 
