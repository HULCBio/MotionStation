% CAMPOS   カメラの位置
% 
% CP = CAMPOS              カレントのaxesのカメラの位置を取得します。
% CAMPOS([X Y Z])          カメラの位置を設定します。
% CPMODE = CAMPOS('mode')  カメラの位置のモードを取得します。
% CAMPOS(mode)             カメラ位置のmodeを設定します。
%                          (modeは、'auto'、'manual' のいずれかです)
% CAMPOS(AX,...)           カレントのaxesを AX にします。
%
% CAMPOS は、軸の CameraPosition または CameraPositionMode プロパティ
% を設定、あるいは取得します。
%
% 参考：CAMTARGET, CAMVA, CAMPROJ, CAMUP.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:37 $

