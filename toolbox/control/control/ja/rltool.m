% RLTOOL   SISO Design Tool をオープンし、根軌跡設計のための設定を行います。
% 
% RLTOOL は、Root Locus ビューをオンにした SISO Design Tool をオープン
% します。この GUI を使って、Root Locus 手法を使って、単入力/単出力(SISO)
% 補償器を対話型で設計することができます。プラントモデルをSISO Design Tool
% に取り込むため、File メニューから Import Model アイテムを選択します。
% デフォルトでは、つぎのフィードバックコンフィギュレーションが設定され
% ています。
% 
%          u --->O--->[ COMP ]--->[ PLANT ]----+---> y
%              - |                             |
%                +-----------------------------+
% 
% RLTOOL(PLANT) は、SISO Tool 内で使用されるプラントモデル PLANT を指定
% します。PLANT は、TF, ZPK, SS のいずれかを使って作成される線形モデルです。
% 
% RLTOOL(PLANT,COMP) は、補償器(これも、TF, ZPK, SS のいずれかを使って
% 作成した線形モデルです)に対する初期値 COMP も設定します。
% 
% RLTOOL(PLANT,COMP,LocationFlag,FeedbackSign) は、つぎのようにして、
% 補償器の位置とフィードバックの符号を変更します。
%
%    LocationFlag = 1: 補償器をフォワードループに置く
%    LocationFlag = 2: 補償器をフィードバックループに置く
%    
%    FeedbackSign = -1: 負のフィードバック
%    FeedbackSign =  1: 正のフィードバック
% 
% 参考：   SISOTOOL.


%   Karen D. Gondoly
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2003/06/26 16:04:46 $
