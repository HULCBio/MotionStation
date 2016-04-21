% C2DT   
%
% 連続状態空間モデルを、入力に時間遅れをもたせながら、離散時間モデルに
% 変換します。
%
% [Ad,Bd,Cd,Dd] = C2DT(A,B,C,T,lambda) は、連続時間システム
%           .
%           x(t) = Ax(t) + Bu(t-lambda)
%           y(t) = Cx(t) 
%
% を、サンプル時間 T をもつ離散時間システム
%
%         x(k+1) = Ad x(k) + Bd u(k)
%           y(k) = Cd x(k) + Dd u(k) 
%
% に、変換します。
% 
% 参考 : PADE.


%   G. Franklin 1-17-87
%   Revised 8-23-87 JNL
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:30 $
