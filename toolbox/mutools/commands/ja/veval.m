% function [out1,out2,out3,...] = veval(name,in1,in2,in3,...)
%
% MATLABのFEVALのように機能し、VARYINGおよびCONSTANT/SYSTEM行列に対して
% も機能します。NAMEは、MATLAB関数名 (ユーザが作成した、またはMATLABが提
% 供するもの)を表わすキャラクタ文字列です。関数は、独立変数値で各々の入
% 力引数に適用されます。任意のCONSTANT/SYSTEM行列は、独立変数を通してス
% イープがなされますが、その値を保持します。出力引数は10個に制限されてい
% て、入力引数は13個に制限されています。これらは、簡単に変更することがで
% きます。
%
% VEVALは、VARYINGシステム行列を簡単に作成するために使われます。
%
% 参考: EVAL, FEVAL, VEBE.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
