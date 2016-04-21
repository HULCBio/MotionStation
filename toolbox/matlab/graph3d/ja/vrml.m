% VRML   グラフィックスをVRML 2.0ファイルに保存
% 
% VRML(H,FILENAME) は、ハンドル番号が H であるオブジェクトとその子を
% VRML 2.0ファイルに保存します。
% FILENAME が拡張子をもたなければ、".wrl" が追加されます。FILENAME と
% いうファイルが存在すれば、上書きされます。
% VRML(H) は、 H とその子をファイル "matlab.wrl" に保存します。
%
% VRMLファイルは、ブラウザでVRML 2.0プラグインを使って見ることができます。
% 使用可能なプラグインがいくつかあります。プラグインLive3DとCosmoplayer
% は、VRMLの出力に使うことができます。これらのプラグインは、つぎのURLか
% らダウンロードできます。
% 
%     http://vrml.sgi.com/cosmoplayer/index.html
%     http://www.netscape.com/comprod/products/navigator/version_3.0...
%           /multimedia/live3d/index.html
% 
% 重要点：
% VRML 1.0プラグインの場合、VRML 2.0ファイルは問題なく読めます。しかし、
% 表示はされません。VRML 2.0プラグインを使ってください。
%
% MATLABとプラグイン間では、レンダリングが異なることに注意してください。
% これらの違いの一部は、プラグインが実現していないVRML 2.0 specの機能に
% よるものです。それ以外は、VRML.mが実現していない機能によるものです。
% MATLABが提供している機能が、VRML 2.0 specの一部ではない場合があります。
%
% プラグイン毎にサポートされている機能の詳細については、ベンダーのリリース
% ノートを参照してください。CosmoPlayer Beta 3aでは、つぎのURLにあります。
% 
%    http://vrml.sgi.com/cosmoplayer/beta3/releasenotes.html.
%
% CosmoPlayerでサポートされていない重要な機能：
% 
%    カラーの補間
%    テキスト
%    
% つぎのMATLABの機能は、VRML.mではサポートされていません。将来の
% リリースで追加されることを予定しています。
% 
%    テクスチャマップ
%    軸の目盛り
%    'Box'プロパティ(常にonに設定されています)
%    Axes の X,Y,Z の Dir プロパティ
%    マーカ
%    NaN の扱い
%    トゥルーカラーの CData
%
% つぎのMATLABの機能は、VRML 2.0 specにはありません。
% 
%   VRML 2.0のラインスタイル
%   正射影
%   PhongライティングとGouraudライティング
%   パッチとサーフェスオブジェクトの枠のラインの'Stitching'


%   R. Paxson, 4-10-97.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $
