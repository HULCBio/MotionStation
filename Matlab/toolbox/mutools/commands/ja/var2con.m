% function [matout,ivval] = var2con(mat,desiv)
%
% VARYING行列をCONSTANT行列に変換します。入力引数MATが1つで、それがVAR-
% YING行列の場合、出力MATOUTは独立変数の最初の値に関連したCONSTANT行列に
% なります。オプションである2番目の出力引数は、独立変数値です。2つの入力
% 引数が使われる場合、最初の引数はVARYING行列で、2番目は希望する独立変数
% 値です。コマンドは、DESIVに最も近い独立変数値をもつMATの中の行列を求め、
% その行列をCONSTANT行列として出力します。
%
% 参考: XTRACT, XTRACTI.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
