% LOOPSTRUCT   フィードバックループの構成を描画
%
% Handles = LOOPSTRUCT(ConfigID,AxisHandle,Render) は、ハンドル AXISHANDLE 
% をもつ座標軸内の CONFIGID の数をもつループ構成を描画します。
% 以下の RENDER を含むことができます。
%     1) 'plain':  just the loop topology sketch
%     2) 'signal': 信号名を含みます
%
% 座標軸の範囲は、適切なループ構造体のスケールを保証するために、両方の
% 座標軸に従って0-1の間に設定されます。座標軸上の任意の子オブジェクトは、
% 新規のフィードバック構成を描画する前に消去されます。


%   Author(s): Karen D. Gondoly
%              P. Gahinet 3/00
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:06:57 $