% WTBXMNGR      Wavelet Toolbox の管理
%
% WTBXMNGR または WTBXMNGR('version') は、ツールボックスのモード
% (バージョン 1.x vs 2.x) のカレントバージョンを表示します。
% 
% WTBXMNGR('V1') または WTBXMNGR('v1') は、Version 1.x のウェーブレット
% パケットの管理モードを設定します。(これは古いモードです)
% 
% WTBXMNGR('V2') または WTBXMNGR('v2') は、Version 2.x のウェーブレット
% パケットの管理モードを設定します。ウェーブレットパケットオブジェクト
% が使われます。(WPTREE を参照)
%
% WTBXMNGR('LargeFonts') は、Large Fonts の受け入れ可能な方法でつぎに
% 作成された figure の大きさを設定します。
%
% WTBXMNGR('DefaultSize') は、つぎに作成された figure に対するデフォ
% ルトの figure サイズを再格納します。
%
% WTBXMNGR('FigRatio',ratio) は、0.75 <= ratio <= 1.25 として、"ratio"
% によって、デフォルトの大きさに乗算することで、つぎに作成された figure
% の大きさを変更します。
%
% WTBXMNGR('FigRatio') は、カレントの ratio 値を出力します。


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-Feb-98.
%   Copyright 1995-2002 The MathWorks, Inc.
