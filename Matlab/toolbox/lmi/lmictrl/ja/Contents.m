% LMI Control Toolbox
% Version 1.0.9 (R14) 05-May-2004
%
%             A. 解析と設計のためのツール
%             ----------------------------
%
% ノミナル性能の評価
%    norminf     - 連続時間システムのRMS/Hinfゲイン
%    dnorminf    - 離散時間システムのRMS/Hinfゲイン
%    norm2       - 連続時間システムのH2ノルム
%
% ロバスト性解析
%    quadstab    - 2次安定性
%    quadperf    - 2次Hinf性能
%    pdlstab     - パラメトリックなLyapunov関数によるロバスト安定性
%    popov       - ロバスト安定性に対するPopov基準
%    decay       - 2次減衰率
%    mubnd       - 構造化特異値の上界
%    mustab      - ロバスト安定余裕(mu)
%    muperf      - ロバストHinf性能(mu)
%
% Hinfの設計- 連続時間
%    msfsyn      - 多目的状態フィードバック設計
%    hinflmi     - LMIベースのHinf設計
%    hinfmix     - 極配置を使ったH2/Hinf混合設計
%    lmireg      - 極配置に対するLMI領域の設定
%    hinfric     - RiccatiベースのHinf設計
%
% Hinfの設計- 離散時間
%    dhinflmi    - LMIベースのHinf設計
%    dhinfric    - RiccatiベースのHinf設計
%
% ループ整形
%    magshape    - 整形フィルタ設計のためのGUI
%    sconnect    - 一般的な制御ループの設定
%    frfit       - 周波数応答データの有理近似
%
% ゲインスケジューリング
%    hinfgs      - ゲインスケジューリングHinf設計
%    pdsimul     - 与えられたパラメータ軌道に沿った時間応答
%
% デモ
%    sateldem    - 衛星の状態フィードバックコントロール
%    radardem    - レーダアンテナのループ整形設計
%    misldem     - ミサイルのオートパイロットのゲインスケジューリング制
%                  御
%
%
%          B. 不確かさ線形システム
%          -------------------------------------------
%
% 線形時不変システム
%    ltisys      - 状態空間モデルをSYSTEM行列として格納
%    ltiss       - SYSTEM行列から状態空間データを抽出
%    ltitf       - SISOシステムの伝達関数の計算
%    islsys      - SYSTEM行列かどうかをテスト
%    sinfo       - システムの情報
%    sresp       - システムの周波数応答
%    spol        - システムの極の算出
%    ssub        - サブシステムの抽出
%    sinv        - 逆システムを計算
%    sbalanc     - 状態空間実現の数値的平衡化
%    splot       - 時間応答と周波数応答のプロット
%
% ポリトピックシステム、または、パラメータ依存システム(P-システム)
%    psys        - P-システムの設定
%    psinfo      - P-システムに関する情報の出力
%    ispsys      - P-システムであるかどうかをテスト
%    pvec        - 不確かさ、または、時変パラメータのベクトルの設定
%    pvinfo      - パラメータベクトルの記述の読み込み
%    polydec     - パラメータボックスの端点を指定するポリトピック座標
%    aff2pol     - P-システムに対するアフィン/ポリトピック変換
%    pdsimul     - パラメータ軌道に沿ってP-システムをシミュレーション
%
% 動的不確かさ
%    ublock      - 不確かさブロックの設定
%    udiag       - ブロック対角な不確かさの設定
%    uinfo       - ブロック対角な不確かさの記述を表示
%    aff2lft     - アフィンP-システムの線形分数表現
%
% システムの相互接続
%    sdiag       - 線形システムの付加
%    sderiv      - 比例-微分器
%    sadd        - システムの並列結合
%    smult       - システムの直列結合
%    sloop       - フィードバックループ
%    slft        - 線形分数フィードバック相互接続
%    sconnect    - 標準制御ループの結合
%



% Copyright 1995-2004 The MathWorks, Inc. 
