% IDUIFILE は、ident の中のファイル操作を取り扱います。
% 
%   引数：
%   load_data   インポートデータ変数用のダイアログボックスのオープン
%   load_iodata i/o 型でのデータのインポート用のダイアログボックスをオー
%               プン
%   load_model  インポートするモデルに対するダイアログボックスのオープン
%   load_mat    選択した mat ファイルをロード
%   done_data   データを読み込んだときの最終操作
%   reset       ダイアログの種々のボックスをリセット
%   insert      i/o データを summary board に転送
%   test1       サンプリング間隔が妥当か否かをテスト
% この関数は、ワークスペースでいくつかの演算を行うスクリプトファイル 
% IDUIFSCR と共に機能します。

%   Copyright 1986-2001 The MathWorks, Inc.
