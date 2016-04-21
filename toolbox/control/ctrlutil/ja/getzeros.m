% GETZEROS   状態空間モデルの零点を計算
% 
% Z = GETZEROS(A,B,C,D,E) は、データ(A, B, C, D, E) をもつ状態空間モデル
% の伝達零点 Z を出力します。
%
% [Z,GAIN] = GETZEROS(A,B,C,D,E) は、SISO モデルに対して、伝達関数のゲイン
% も出力します。
% 
% 低水準ユーテリティ


%   Author: P.Gahinet 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/06/26 16:08:32 $
