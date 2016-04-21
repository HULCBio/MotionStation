% function [sys,fit,extracons] = magfit(vmagdata,dim,wt)
%
% MAGFITは、与えられた周波数領域重み関数WTを使って、ゲインデータVMAGDATA
% を安定な最小位相伝達関数で近似します。VMAGDATAは、一致するゲインと周波
% 数点を与えるVARYING行列です。
%
%   [mag,rowpoint,omega,err] = vunpck(vmagdata)
%
% DIMは、1行4列ベクトルで、dim= [hmax,htol,nmin,nmax]です。出力SYSTEM行
% 列SYSは、つぎを満たす安定な最小位相SISOシステムです。
%
%        1/(1+ h/W) < g^2/mag^2 < 1+ h/W
%
% ここで、gは[W,rowpoint,omega,err] = vunpck(WT)のとき、周波数omegaに対
% するSYSの周波数応答の大きさです。SYSの次数はNで、0<=NMIN<=N<=NMAXはH<=
% HMAXを満たす最小次数です。そのようなnが存在しないときは、N=NMAXになり
% ます。Hの値は、hupper-hlower<=HTOLのときに上界と下界の間で近似的に最小
% 化されます。FITは、Hの到達値です。
%
% 参考: FITMAG, FITMAGLP, MUSYNFIT, MUSYNFLP.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
