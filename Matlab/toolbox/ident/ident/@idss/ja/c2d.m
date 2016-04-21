% IDSS/C2Dは、連続時間モデルを離散時間モデルに変換します。
%
%   SYSD = C2D(SYSC,Ts,METHOD)
%
%   SYSC   : IDSS オブジェクトの連続時間モデル
%
%   Ts     : サンプリング間隔
%   METHOD : 'Zoh' (デフォルト)、または、'Foh' のいずれかで、入力がゼロ
%            次ホールド(区分的に一定)されるか、一次ホールド(区分的に線形
%             )されるかを示します。
%   SYSD   : 離散時間モデル、'SSParameterization' = 'Free'をもつ IDSS オ
%            ブジェクトです。
%
% 共分散行列は変換されないことに注意してください。  
%

% $Revision: 1.2 $ $Date: 2001/03/01 22:56:21 $
%   Copyright 1986-2001 The MathWorks, Inc.
