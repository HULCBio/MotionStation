% CAMUP   カメラの上向きベクトル
% 
% UP = CAMUP               カレントのaxesのカメラの上向きベクトルを取得
%                          します。
% CAMUP([X Y Z])           カメラの上向きベクトルを設定します。
% UPMODE = CAMUP('mode')   カメラの上向きベクトルモードを取得します。
% CAMUP(mode)              カメラの上向きベクトルモードの設定
%                          (modeは 'auto'、'manual' のいずれかです)
% CAMUP(AX,...)            カレントのaxesの代わりに AX を使用します。
%
% CAMUP は、CameraUpVector プロパティまたは CameraUpVectorMode プロ
% パティを設定あるいは取得します。
%
% 参考：CAMPOS, CAMTARGET, CAMPROJ, CAMUP.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:42 $

