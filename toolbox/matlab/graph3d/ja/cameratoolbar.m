% CAMERATOOLBAR   対話話的にカメラを操作
% 
% CAMERATOOLBAR は、figureウィンドウ上でマウスをドラッグすることによ
% り、カメラやライトを対話的に操作することのできる新しいツールバーを
% 作成します。カレント軸(gca)のカメラプロパティは影響を受けます。
% ツールバーが初期化されたときに、いくつかのカメラプロパティが設定され
% ます。
%
% CAMERATOOLBAR('NoReset') は、カメラプロパティの設定を行わないで
% ツールバーを作成します。
% 
% CAMERATOOLBAR('SetMode' mode) は、ツールバーのモードを設定します。
% 設定できるモードは、つぎのものです。:'orbit', 'orbitscenelight',
% 'pan', 'dollyhv', 'dollyfb', 'zoom', 'roll', 'walk', 'nomode'
%
% CAMERATOOLBAR('SetCoordSys' coordsys) は、カメラの移動の主軸を設定
% します。coordsys は、'x', 'y', 'z', 'none' のいずれかです。
%
% CAMERATOOLBAR('Show') は、ツールバーを表示します。
% CAMERATOOLBAR('Hide') は、ツールバーを非表示にします。
% CAMERATOOLBAR('Toggle') は、ツールバーの可視状態を切り替えます。
%
% CAMERATOOLBAR('ResetCameraAndSceneLight') は、カレントのカメラと光源を
% リセットします。
% 
% CAMERATOOLBAR('ResetCamera') は、カレントのカメラをリセットします。
% CAMERATOOLBAR('ResetSceneLight') は、カレントの光源をリセットします。
% CAMERATOOLBAR('ResetTarget') は、カレントのカメラターゲットをリセット
% します。
%
% ret = CAMERATOOLBAR('GetMode') は、カレントモードを出力します。
% ret = CAMERATOOLBAR('GetCoordSys') は、カレント主軸を出力します。 
% ret = CAMERATOOLBAR('GetVisible') は、可視性を出力します。
% ret = CAMERATOOLBAR は、ツールバーに対するハンドルを出力します。
%
% CAMERATOOLBAR('Close') は、ツールバーを削除します。
%
% 注意：レンダリング性能は、OpenGLハードウェアに影響を受けます。
%
% 参考：ROTATE3D, ZOOM.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 01:54:32 $
