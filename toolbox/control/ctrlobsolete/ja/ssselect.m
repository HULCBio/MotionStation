% SSSELECT   より大きなシステムからサブシステムを抽出
% 
% [Ae,Be,Ce,De] = SSSELECT(A,B,C,D,INPUTS,OUTPUTS) は、指定した入力と
% 出力をもつ状態空間サブシステムを出力します。ベクトル INPUTS と OUTPUTS 
% は、それぞれ、システムの入力を出力のインデックスを含んでいます。
%
% [Ae,Be,Ce,De] =  SSSELECT(A,B,C,D,INPUTS,OUTPUTS,STATES) は、指定した
% 入力、出力、状態をもつ状態空間サブシステムを出力します。
%
% 参考 : SSDELETE.


%   Clay M. Thompson 6-26-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:24 $
