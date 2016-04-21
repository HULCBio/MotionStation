% Robust Control Toolbox
% Version 2.0.10 (R14) 05-May-2004
%
%
% 新機能
%   Readme     - Robust Toolboxに関する重要なリリース情報
%                (Readmeをダブルクリックするか、"whatsnew directoryname"
%                とタイプしてください。たとえば、"whatsnew robust"と
%                タイプすると、このファイルを表示します)。
%
% システムデータ構造に付随するもの
%    branch    - ツリーから構成要素の取り出し
%    graft     - ツリーデータへ追加
%    issystem  - システム変数のチェック
%    istree    - ツリー変数のチェック
%    mksys     - システムのツリー変数の作成
%    tree      - ツリー変数の作成
%    vrsys     - 標準システム変数名の出力
%
% モデル作成
%    augss     - プラントの拡大(状態空間モデル)
%    augtf     - プラントの拡大(伝達関数)
%    interc    - 一般的な多変数システムの相互結合
%
% モデルの変換
%    bilin     - 多変数双一次変換
%    des2ss    - 特異値分解によるディスクリプタシステムの状態空間表現へ
%                の変換
%    lftf      - 線形分数変換
%    sectf     - セクタ変換
%    stabproj  - 安定/不安定モード分解
%    slowfast  - slow/fastモード分解
%    tfm2ss    - 伝達関数を状態空間表現に変換
%
% ユーティリティ
%    aresolv   - 一般化連続時間Riccatiソルバ
%    daresolv  - 一般化離散時間Riccatiソルバ
%    riccond   - 連続時間Riccati方程式の条件数
%    driccond  - 離散時間Riccati方程式の条件数
%    blkrsch   - 関数cschurによるブロックの順序による実Schur分解
%    cschur    - 複素Givens回転による順序付けられた複素Schur分解
%
% 多変数Bodeプロット
%    cgloci    - 連続系の特性ゲイン軌跡
%    dcgloci   - 離散系の特性ゲイン軌跡
%    dsigma    - 離散系の特異値Bodeプロット
%    muopt     - 実数/複素数混合の不確かさをもつシステムの構造化特異値の
%                上界(Michael FanのMUSOL4)
%    osborne   - Osborne法による構造化特異値(SSV)の上界
%    perron    - Perron法による固有構造SSV
%    psv       - Perron法による固有構造SSV
%    sigma     - 連続系の特異値Bodeプロット
%    ssv       - 構造化特異値のBodeプロット
%
% 分解
%    iofc      - inner-outer分解(列タイプ)
%    iofr      - inner-outer分解(行タイプ)
%    sfl       - 左スペクトル分解
%    sfr       - 右スペクトル分解
%
% モデル次数の低次元化
%    balmr     - 平衡化打切り法によるモデルの低次元化
%    bstschml  - Schur法による相対誤差モデル低次元化
%    bstschmr  - Schur法による相対誤差モデル低次元化
%    imp2ss    - インパルス応答から状態空間表現への変換
%    obalreal  - 順序付き平衡化実現
%    ohklmr    - 最適Hankel最小次数近似
%    schmr     - Schur法によるモデルの低次元化
%
% ロバスト制御系設計法
%    h2lqg     - 連続時間H_2制御系設計
%    dh2lqg    - 離散時間H_2制御系設計
%    hinf      - 連続時間H_∞制御系設計
%    dhinf     - 離散時間H_∞制御系設計
%    hinfopt   - γ-イタレーションによるH_∞シンセシス
%    normh2    - H_2ノルムの計算
%    normhinf  - H_∞ノルムの計算
%    lqg       - LQG最適制御シンセシス
%    ltru      - LQGループリカバリ
%    ltry      - LQGループリカバリ
%    youla     - Youlaパラメトリゼーション
%
% デモンストレーション
%    accdemo   - バネ-マス系のベンチマーク問題
%    dintdemo  - 二重積分要素をもつプラントのH∞設計
%    hinfdemo  - H_2 & H∞設計の例
%                   戦闘機と大型宇宙構造物
%    ltrdemo   - LQG/LTR 設計例-戦闘機
%    mudemo    - muシンセシスの例題
%    mudemo1   - muシンセシスの例題
%    mrdemo    - ロバスト規範を基にモデルの低次元化
%    rctdemo   - Robust control toolboxのデモ - メインメニュー
%    musldemo  - MUSOL4のデモ


% Copyright 1988--2004 The MathWorks, Inc.
