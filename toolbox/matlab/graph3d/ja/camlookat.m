% CAMLOOKAT   指定したオブジェクトを見るためにカメラとターゲットを移動
%
% CAMLOOKAT(H) は、ベクトルHのオブジェクトに視点を移します。
% CAMLOOKAT(AX) は、AX で識別されるaxesの子オブジェクトに視点を移します。
% CAMLOOKAT は、カレントaxes内の子オブジェクトに視点を移します。
% 
% CAMLOOKAT は、相対的な視点の方向とカメラの視点の角度を保持しながら、
% カメラの位置とカメラのターゲットを移動します。観測されるオブジェクト
% (単数または複数)は、axesの位置を設定する長方形をほぼ満たします。
%
% 参考：CAMORBIT, CAMPAN, CAMZOOM, CAMROLL, CAMPOS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:34 $

