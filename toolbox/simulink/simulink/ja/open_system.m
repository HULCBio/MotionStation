% OPEN_SYSTEM   Simulinkシステムウィンドウまたはブロックダイアログ ボックス
% を開く
%
% OPEN_SYSTEM('SYS') は、指定したシステムウィンドウまたはサブシステムウィン
% ドウを開きます。
%
% OPEN_SYSTEM('BLK') は、'BLK'がブロックの絶対パス名であり、指定したブロック
% に関連するダイアログボックスを開きます。
%
% OPEN_SYSTEM は、付加的な入力引数として、以下のような種々のオプションを設定で
% きます。オプションは以下のとおりです。
%
% DESTSYS    SYS を開くための他のシステムウィンドウを設定。
% この オプションは、'replace' や 'reuse' オプションと共に使用できます。
% SYS と DESTSYS は同じモデル内になければいけないことに注意してください。
%  force           任意のOpenFcnやマスクのあるシステム下でシステムを開く。
% parameter  ブロックのパラメータダイアログを開く
% property   ブロックのプロパティダイアログを開く
% mask       ブロックのマスクダイアログを開く
% OpenFcn    ブロックのOpenFcnを実行
%  replace    他のシステムウィンドウ内にシステムを開いたとき、指定のウィンド
% ウを再利用するか、開かれたシステムの大きさと同じ大きさのウィンドウを設定
% reuse      システムを他のウィンドウシステムに開くとき、ウィンドウを再利用
% し、スクリーンにうまく合うように調整
%
% 上のオプションの組み合わせを使いたい場合があります。
% たとえば、マスクされたブロックをウィンドウに開いて再利用する場合、つぎのよ
% うにします。
%
%  OPEN_SYSTEM(SYS,DESTSYS,'force','replace')
%
% 'force' オプションは、マスクされたブロックに対して、サブシステムウィンドウ
% の下に、open_system がオープンすることが必要となります。
%
% OPEN_SYSTEM が、入力引数としてセル配列を受け入れることに注意してください。
% このことは、OPEN_SYSTEM へのコールをベクトル化できることを意味しています。
%
% 例題:
%
% % 'f14' を開く
% open_system('f14');
%
% % サブシステム 'f14/Controller' を開く
% open_system('f14/Controller')
%
% % 'reuse'モードで、'f14' を'f14/Controller' ウィンドウに開く
% open_system('f14','f14/Controller','reuse');
%
% % open_system のベクトル化
% open_system( { 'f14', 'vdp' });
%
% % 他のベクトル化された open_system は、空の文字列は、演算なしとして
% % 取り扱われ、この結果
% 'f14' は、実行する前に、開くする必要があり
% ます。
% open_system( { 'f14', 'f14/Controller', 'f14' },...
% {  '',   '',               'vdp' }, ...
% {  '',   '',               'replace' } );
%
% 参考 : CLOSE_SYSTEM, SAVE_SYSTEM, NEW_SYSTEM, LOAD_SYSTEM.


% Copyright 1990-2002 The MathWorks, Inc.
