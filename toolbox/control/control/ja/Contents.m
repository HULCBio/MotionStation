% Control System Toolbox
% 
% Version 6.0 (R14) 05-May-2004
% 
% 一般
% ctrlpref    - Control System Toolbox のプリファレンスの設定LTIモデルの様々なタイプの詳細なヘルプ
% ltimodels   - LTIモデルの様々なタイプの詳細なヘルプ
% ltiprops    - 利用可能なLTIモデルプロパティの詳細なヘルプ
% 
% 線形モデルの作成
% tf          - 伝達関数の作成
% zpk         - 零点/極/ゲイン型モデルの作成
% ss, dss     - 状態空間モデルの作成
% frd         - 周波数応答データモデルの作成
% filt        - デジタルフィルタの作成
% set         - LTI モデルのプロパティの設定/変更
% 
% データの抽出
% tfdata      - 分子多項式、分母多項式の抽出
% zpkdata     - 零点/極/ゲインデータの抽出
% ssdata      - 状態空間行列の抽出
% dssdata     - SSDATA のディスクリプタ版
% frdata      - 周波数応答データの抽出
% get         - LTI モデルのプロパティ値の袖出
% 
% 変換
% tf          - 伝達関数への変換
% zpk         - 零点/極/ゲイン型モデルへの変換
% ss          - 状態空間モデルへの変換
% frd         - 周波数応答データへの変換
% c2d         - FRD モデルの周波数点の単位の変更
% d2c         - 連続から離散への変換
% d2d         - 離散時間モデルのリサンプル
% 
% システムの接続
% append      - 入力と出力を追加することによる LTI システムのグループ化
% parallel    - 並列結合(参考 オーバロード +)
% series      - 直列結合(参考 オーバロード *)
% feedback    - 2つのシステムのフィードバック結合
% lft         - 一般的なフィードバック相互接続(Redheffer スター積)
% connect     - ブロックダイアグラム表現から状態空間モデルを作成
% 
% モデルダイナミクス
% dcgain      - D.C. (低周波数)ゲイン
% bandwidth   - システムのバンド幅
% pole, eig   - システムの極
% zero        - システム(伝達)の零点
% pzmap       - 極-零のマップ
% iopzmap     - 入/出力の極-零マップ
% damp        - システムの極に対応する固有振動数と減衰率
% esort       - 実部を参考に連続時間の極をソート
% dsort       - 大きさを参考に離散時間の極をソート
% norm        - LTI システムのノルム
% covar       - 白色ノイズに対する出力共分散
% 
% 時間応答
% ltiview     - 線形応答解析の GUI(LTI Viewer)
% step        - ステップ応答
% impulse     - インパルス応答
% initial     - 初期状態をもつ状態空間システムの自由応答
% lsim        - 任意の入力に対する応答
% gensig      - LSIM 用のための入力信号の生成
% 
% 周波数応答
% ltiview     - 応答計算用の GUI(LTI Viewer)
% bode        - 周波数応答の Bode 線図
% bodemag     - BODE 線図の大きさのみの表示
% sigma       - 特異値周波数プロット
% nyquist     - Nyquist 線図
% nichols     - Nichols 線図
% margin      - ゲイン余裕と位相余裕
% allmargin   - すべてのクロスオーバ周波数と関連するゲイン/位相余裕
% freqresp    - 周波数グリッドにおける周波数応答
% evalfr      - 与えられた周波数での周波数応答の計算
% 
% 古典的な設計
% sisotool    - SISO design GUI (根軌跡とループ整形手法)
% rlocus      - Evans 根軌跡
% 
% 極配置
% place       - MIMO の極配置
% acker       - SISO の極配置
% estim       - 与えられた推定器ゲインから推定器を作成
% reg         - 与えられた推定器ゲインと状態フィードバックゲインから
%                レギュレータを作成
% 
% LQR/LQG 設計
% lqr, dlqr   - 線形2次形式(LQ)状態フィードバックレギュレータ
% lqry        - 出力重み付き LQ レギュレータ
% lqrd        - 連続プラントに対する離散 LQ レギュレータ
% kalman      - Kalman 状態推定器
% kalmd       - 連続プラントに対する離散 Kalman 状態推定器
% lqgreg      - 与えられた LQ ゲインと Kalman 状態推定器による LQG 
%               レギュレータの作成
% augstate    - 状態の追加による出力の拡張
% 
% 状態空間モデル
% rss, drss   - 安定な状態空間モデルをランダムに生成
% ss2ss       - 状態座標変換
% canon       - 状態空間正準型
% ctrb        - 可制御行列
% obsv        - 可観測行列
% gram        - 可制御性グラミアンと可観測性グラミアン
% ssbal       - 状態空間実現の対角平衡化  
% balreal     - グラミアンに基づく入力/出力平衡化
% modred      - モデルの状態の除去
% minreal     - 極/零点消去による最小実現
% sminreal    - 構造的最小実現
% 
% 周波数応答データ(FRD)モデル
% chgunits    - 周波数ベクトル単位の変換
% fcat        - 周波数応答のマージ
% fselect     - 周波数範囲またはサブグリッドの選択
% fnorm       - 周波数関数点でのピークゲイン
% abs         - 周波数応答のゲイン
% real, imag  - 周波数応答の実部と虚部
% interp      - 周波数応答データの補間
% 
% 時間遅れ
% hasdelay    - むだ時間をもつモデルかどうかを判定
% totaldelay  - 各入力/出力の組毎の遅れの総量
% delay2z     - z = 0への極の再配置または周波数応答データ(FRD)の位相シフト
% pade        - むだ時間の Pade 近似
% 
% モデルの次数と特性
% class       - モデルタイプ('tf'、'zpk'、'ss'、または、'frd').
% isa         - LTI モデルの型の検出
% size        - モデルサイズと次数
% ndims       - 次元数
% isempty     - LTI モデルが空の場合、真
% isct        - 連続時間モデルの場合、真
% isdt        - 離散時間モデルの場合、真
% isproper    - プロパな LTI モデルの場合、真
% issiso      - 単入力単出力モデルの場合、真
% reshape     - LTI モデルの配列のサイズ変更
% 
% オーバロードされた演算子
% + と -     - LTI システムの加算と減算(並列結合)
% *           - LTI システムの乗算(直列結合)
% \           - 右除算 -- sys1/sys2 は、sys1*inv(sys2) です。
% /           - 右除算 -- sys1/sys2 は、sys1*inv(sys2) です。
% ^           - LTI モデルのベキ乗
% '           - 共役転置.
% .'          - 入出力マップの転置
% [..]        - 入力または出力に沿った LTI モデルの結合
% stack       - 配列の次元に沿った LTI モデル/配列の組み込み
% inv         - LTI システムの逆システム
% conj        - モデル係数の複素共役
% 
% 行列方程式の解法
% (d)lyap     - (離散)連続 Lyaponov 方程式の解法
% (d)lyapchol - 安定Lyaponov方程式に対するソルバに乗和
% care        - 連続代数 Riccati 方程式をの解法
% dare        - 離散代数の Riccati 方程式の解法
% gcare       - 一般化Riccati方定期の開放(連続時間)
% gdare       - 一般化Riccati方定期の開放(離散時間))
% 
% デモンストレーション
% 利用可能なデモのリストについては、"demo" または "help ctrldemos" と
% タイプしてください。
% 
% Copyright 1986-2004 The MathWorks, Inc.
