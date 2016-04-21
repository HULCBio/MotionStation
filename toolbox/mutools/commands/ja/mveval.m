% function [out1,out2,out3,...] = mveval(name,mask,in1,in2,in3,...)
%
% MATLABのFEVALのように機能し、VARYING行列とCONSTANT/SYSTEM行列に対して
% も機能します。NAMEは、MATLAB関数名(ユーザが作成した、またはMATLABが提
% 供するもの)を表わすキャラクタ文字列です。関数は、独立変数値で各々の入
% 力引数に適用されます。任意のCONSTANT/SYSTEM行列は、独立変数を通してス
% イープがなされますが、その値を保持します。出力引数は、最大10個に制限さ
% れていて、入力引数は、最大13個に制限されています。これらは、簡単に変更
% することができます。VEVALは、VARYINGシステム行列を簡単に作成するために
% 使われます。
%
% 参考: EVAL, FEVAL, VEBE, VEVAL.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
