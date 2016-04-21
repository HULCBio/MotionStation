% SISOTOOL   SISO Design Tool
%
% SISOTOOL は、SISO Design Tool を開きます。
% このグラフィカルユーザインタフェース(GUI)は、根軌跡図や開ループの Bode 線図を
% 使って、単入力/単出力(SISO)の補償器を設計することができます。プラントモデル
% を SISODesign Tool に読み込むにはFile メニューからImport Model アイテムを
% デフォルトでは、フィードバックコンフィギュレーションはつぎのようになります。
%
%              r -->[ F ]-->O--->[ C ]--->[ G ]----+---> y
%                         - |                      |
%                           +-------[ H ]----------+
%
% SISOTOOL(G) は、SISO Tool の中でプラントモデル G を設定します。
% G は、TF, ZPK, SS のいずれかを使って作成した任意の線形モデルです。
%
% SISOTOOL(G,C) は、更に補償器 C に対する初期値を指定します。
% 同様に、SISOTOOL(G,C,H,F) は、センサ H とプレフィルタ F に対する付加的な
% モデルを与えます。
%
% SISOTOOL(VIEWS) または、SISOTOOL(VIEWS,G,...) は、SISO Tool の初期コンフィギュ
% レーションを設定します。VIEWS は、つぎの文字列のいずれか(または、それらを
% 合わせたもの)です。
%   'rlocus'      根軌跡図
%   'bode'        開ループ応答の Bode線図
%   'nichols'     開ループ応答の Nicholsプロット
%   'filter'      プレフィルタ F の Bode線図
% たとえば、
%   sisotool({'nichols','bode'}) 
% は、Nicholsプロットと開ループのBode線図を示す SISO Design Tool を開きます。
%
% デフォルトの補償器の位置とフィードバックの符号を変更するには、つぎの  
% フィールドをもつ別の入力引数 OPTIONS (構造体) を使ってください。
%    OPTIONS.Location   Cの位置 (フォワードループ   'forward'
%                                フィードバックループ 'feedback')
%    OPTIONS.Sign       フィードバック符号 (負に対して -1, 正に対して +1)
%
% 参考 : LTIVIEW, RLOCUS, BODE, NICHOLS.


% Copyright 1986-2002 The MathWorks, Inc.
