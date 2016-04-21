% Simulink: 一般的なモデルのデモンストレーションと例題
%
% デモンストレーションモデル(.mdl)
%   bangbang     - 状態イベントハンドリングのデモ
%   bounce       - reset integratorを用いたボールのバウンドするデモ
%   countersdemo - カウンタのデモ
%   dblcart1     - 2つのカートのデモ
%   dblpend1     - 2重振子のデモ、バージョン1
%   dblpend2     - 2重振子のデモ、バージョン2
%   hardstop     - hard stopをもつ摩擦モデル
%   hydcyl       - 油圧シリンダモデル
%   hydcyl4      - 4個の油圧シリンダ
%   hydrod       - スティッフなロッドと接続した2つの油圧シリンダ
%   onecart      - 単一のカート/バネのデモ
%   penddemo     - 倒立振子(カート上)のアニメーション
%   simppend     - 単振子のデモ
%   simquat      - アニメーションを使った四元数の回転
%   slprimes     - Simulink による素数の計算
%   thermo       - 住宅の熱力学
%   toilet       - トイレのタンクを流すアニメーション
%   vdp          - Van der Pol方程式システム
%
% デモンストレーションスクリプト
%   vdpdemo    - Van der Pol方程式
%
% MATLABコマンド"demo simulink"を実行することによって、このディレクトリ
% のほとんどのデモとモデルのメニューが表示されます。デモメニューは、
% メインのSimulinkブロックライブラリのDemosブロックを開くことによっても
% 利用可能です(MATLAB コマンドラインで"simulink"とタイプするか、または、
% Simulink toolbarアイコンを押すことによって表示されます)。
%
% デモは、MATLABコマンドラインで、それらの名前をタイプすることによっても
% 実行できます。
%
% サポートルーチンとデータファイル
%   animinit.m      - 種々のデモのアニメーションの初期化
%   crtanim1.m      - onecartのアニメーション
%   crtanim2.m      - dblcart1のアニメーション
%   dblcart1.mat    - dblcart1のデータ
%   dblpend1.mat    - dblpend1のデータ
%   dblpend2.mat    - dblpend2のデータ
%   eulrot.c        - simquatのrateからEular角を計算するS-Function
%   eulrotdisplay.m - simquatのS-Functionを表示
%   lights.mdl      - slprimes の light ブロックをもつ Simulink ライブラリ
%   newhcd.mat      - hydcyl, hydcyl4, hydrodのデータ
%   pendan.m        - penddemoアニメーションのS-Function
%   pndanim1.m      - simppendのアニメーション
%   pndanim2.m      - dblpend1のアニメーション
%   pndanim3.m      - dblpend2のアニメーション
%   slight.m        - Light ブロック S-function
%   thermdat.m      - thermoのフロントエンドスクリプト
%   toilet.wav      - toiletアニメーションのサウンド
%   toiletgui.m     - toiletアニメーションのGUI
%   toiletsfun.m    - toiletアニメーションのS-Function
%   vdpdemo.m       - vdpのフロントエンドスクリプト


% Copyright 1990-2002 The MathWorks, Inc.
