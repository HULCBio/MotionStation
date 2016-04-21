%  function [izs,dzs]=nnsetup(lmisys)
%
% LMIデータをMATLAB表現からNesterov/Nemirovskiiのソルバで利用される表現
% に変換。
%
%  入力:
%   LMI_SET     各LMIの次元と構造を指定する整数値配列
%   LMI_VAR     VARIABLE行列X1,...,Xnを記述する整数値配列
%   LMI_TERM    LMIのすべての項の係数を含む配列
%
%  出力:
%   IZS,DZS     Nesterov/Nemirovskyのソルバへの入力
%

% Copyright 1995-2001 The MathWorks, Inc. 
