% function [matout,err] = xtract(mat,ivlow,ivhigh)
% または
% function [matout,err] = xtract(mat,desiv)
%
% 3入力引数:
% ==================
% 独立変数値がIVLOWとIVHIGHの間であるVARYING行列の部分を抽出します。XT-
% RACTは、独立変数値が昇順に並べられていると仮定します。必要な場合、SO-
% RTIVを使います。
%
% 2入力引数:
% ==================
% 独立変数値が2番目の入力引数の値に最も近い(絶対値で)VARYING行列が、VA-
% RYING行列として(2番目の引数内の要素数と同じ点数で)抽出されます。
%
% 参考: SEL, VAR2CON, VPCK, VUNPCK, XTRACTI.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
