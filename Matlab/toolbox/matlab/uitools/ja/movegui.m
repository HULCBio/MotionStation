% MOVEGUI  GUI figureをスクリーンの指定した部分に移動
%
% MOVEGUI(H, POSITION) は、ハンドル H に関連するfigureを、サイズを保持
% したまま、スクリーンの設定した部分に移動します。
%
% H は、figureのハンドル、またはfigureに関連するあるブジェクトのいずれか
% を設定できます(たとえば、pushbutton uicontrol を含むfigureを、pushbutton 
% 関数ハンドルのコールバックから移動することができます)。
%
% 引数 POSITION は、つぎのいずれかの文字列を採用することができます。
%     'north'     - スクリーンの中央の上部のエッジ
%     'south'     - スクリーンの中央の下部のエッジ
%     'east'      - スクリーンの中央の右エッジ
%     'west'      - スクリーンの中央の左エッジ
%     'northeast' - スクリーンの上部の右端
%     'northwest' - スクリーンの上部の左端
%     'southeast' - スクリーンの下部の右端
%     'southwest' - スクリーンの下部の左端
%     'center'    - スクリーンの中央
%     'onscreen'  - カレントの位置に最も近いスクリーンの位置
%
% 引数 POSITION は、2要素ベクトル [H,V] で設定します。ここで、符号により
% H は、スクリーンの左端から、または右端からのfigureのオフセットを指定し、
% V は、スクリーンの上、または下からのオフセットを設定します。
% 単位は、ピクセルです。
% 
%     H ( h >= 0) は、左端からのオフセット
%     H ( h < 0)  は、右端からのオフセット
%     V ( v >= 0) は、下からのオフセット
%     V ( v < 0) は、上からのオフセット
%
% MOVEGUI(POSITION) は、GCBF または GCF を指定した位置に移動します。
%
% MOVEGUI(H) は、指定したfigureの'onscreen' に移動します。
%
% MOVEGUI は、GCBF または GCF 'onscreen'を移動します(保存したfigure
% 用に文字列ベースのCreateFcn コールバックとして利用可能で、保存し
% た位置に関わらず、再ロードしたときonscreenに表れることを保証します)。
%
% MOVEGUI(H, <event data>)
% MOVEGUI(H, <event data>, POSITION) は、関数ハンドルのコールバックとして
% 使用したとき、指定したfigureをデフォルトの位置に移動するか、または、
% 指定した位置に移動します。この場合、自動的に渡されたイベントデータ
% 構造を無視します。
%
% 例題：
% この例題は、保存された GUI がスクリーンサイズと分解能の違いや、保存
% したものと、再ロードしたときのマシンの違いに関わらず、保存されたGUIが、
% 再ロードされたときにonscreen に表れることを保証する方法として有効である
% ことを示します。スクリーンの CreateFcn コールバックとしてMOVEGUI を割り
% 当てて、スクリーンとは別にfigureを作成します。そして、figureを保存して
% 再ロードします。
%
%    	f=figure('position', [10000, 10000, 400, 300]);
%    	set(f, 'CreateFcn', 'movegui')
%    	hgsave(f, 'onscreenfig')
%    	close(f)
%    	f2 = hgload('onscreenfig')
%
% 以下は、追加引数をもつ、もたないに関わらず、文字列と関数ハンドルを
% 使ってCreateFcn としてMOVEGUI を設定する種々の方法で、種々の挙動を
% 示す例です。
%
%    	set(gcf, 'CreateFcn', 'movegui center')
%    	set(gcf, 'CreateFcn', @movegui)
%    	set(gcf, 'CreateFcn', {@movegui, 'northeast'})
%    	set(gcf, 'CreateFcn', {@movegui, [-100 -50]})
%
% 参考 ： OPENFIG, GUIHANDLES, GUIDATA, GUIDE.


%   Damian T. Packer 2-5-2000
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 02:08:34 $
