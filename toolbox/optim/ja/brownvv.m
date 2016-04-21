% BROWNVV   フル行列の構造化されたHessianの非線形最小化
%
% [F,G,HINFO] = BROWNVV(X,V) は、目的関数 F、勾配 G、HINFOにおける
% F のHessianのパートを計算します。例えば、
%       F = FHAT(X) - 0.5*X'*V*V'*X
%       G は F の勾配 
%            G = FHAT(X)の勾配 - V*V'*X
%       Hinfo は FHAT のHessian
%       (H はフルの形式ではありませんが、
%       H = Hinfo - V*V' を満たします。HMFBX4 を参照)


%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2003/05/01 13:00:51 $
