% XPCTEST - xPC Target テスト
% 
% xpctest は、つぎの xPC Target モジュールの正常な機能をチェックするための
% xPC Target テストを実行します。
% 
%    1. ホストからターゲットまでの通信の初期化
%    2. Target Environment をリセットするために、ターゲットをリブート
%    3. xPC Target アプリケーションをビルド
%    4. xPC Target アプリケーションをターゲットにダウンロード
%    5. ホスト - ターゲットでの通信
%    6. Target アプリケーションの実行
%    7. シミュレーション結果とTarget アプリケーション実行結果との比較 
% xpctest('noreboot') は、テスト 2 をスキップします。ターゲットハードウエ
% アがソフトウエアリブートをサポートしていない場合は、このオプションを使用
% します。

%   Copyright 1994-2002 The MathWorks, Inc.
