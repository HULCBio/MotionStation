% SSDELETE   状態空間システムから入力、出力、状態を削除
% 
% [Ar,Br,Cr,Dr] = SSDELETE(A,B,C,D,INPUTS,OUTPUTS) は、システムから指定
% した入力、出力を除去した状態空間システムを出力します。ベクトル INPUTS 
% と OUTPUTS は、システムの入力と出力です。
%
% [Ar,Br,Cr,Dr] = SSDELETE(A,B,C,D,INPUTS,OUTPUTS,STATES) は、システム
% から指定した入力、出力、状態を除去した状態空間システムを出力します。
%
% 参考 : SSSELECT.


%   Clay M. Thompson 6-27-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:23 $
