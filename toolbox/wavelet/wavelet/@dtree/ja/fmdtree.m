%FMDTREE   DTREE オブジェクトのフィールド管理
%   VARARGOUT = FMDTREE(OPT,T,VARARGIN)
%
%   DTREE オブジェクトの実行に関しては、DTREE クラス用のコンストラクタを%   参照してください。
%
% ユーティリティ:
%===========
%   T がツリーの場合、I は、すべてのノード情報を含む行列 V とインデック
%   スの列を含むノードインデックス C の列ベクトルです。
%
%   V = FMDTREE('an_read',T) は、V = GET(T,'allNI') と等価です。
%   V = FMDTREE('an_read',T,I)
%   V = FMDTREE('an_read',T,I,C)
%   V = FMDTREE('an_read',T,'all',C)
%
%   T = FMDTREE('an_write',T,V) は、T = SET(T,'allNI',V) と等価です。
%   T = FMDTREE('an_write',T,V,'add')
%   T = FMDTREE('an_write',T,V,I)
%   T = FMDTREE('an_write',T,V,'add',C)
%   T = FMDTREE('an_write',T,V,I,C)
%
%   T = FMDTREE('an_del',T,I) は、すべてのノード情報を隠します。
%   I は、ノードインテックすを含むベクトルです。
%

% 内部オプション:
%===============================================================
% OPT = 'setinit', 初期データの設定
% OPT = 'getinit', 初期データの取得
%---------------------------------------------------------------
% allNI - すべてのノード情報: 配列(nbnode,3+nbinfo_by_node)
%   allNI(:,1)     = ノードインデックス
%   allNI(:,2:3)   = ノードデータのサイズ
%   allNI(:,4:end) = クラスに依存
%
%   'an_del'   - すべてのノード情報: 削除
%   'an_write' - すべてのノード情報: 書き込み
%   'an_read'  - すべてのノード情報: 読み込み
%---------------------------------------------------------------
% terNI - 末端ノード情報: セル配列(1,2)
%   c{1} = 配列(nbternod,2)  <--- サイズ
%   c{2} = 配列(1,:)         <--- 情報
%
%   'tn_beglensiz' - 末端ノード情報: begin-length-size
%   'tn_write'     - 末端ノード情報: 書き込み
%   'tn_read'      - 末端ノード情報: 読み込み
%===============================================================

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Jan-97.


%   Copyright 1995-2002 The MathWorks, Inc.
