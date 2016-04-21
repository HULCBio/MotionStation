% 例題とデモ
%
% MATLAB、Toolbox、Simulinkのデモを見るためには、コマンドラインで、
% 'demo' と入力してください。
%
%
% MATLAB/イントロダクション
%   demo        - MATLAB, Toolbox, Simulinkのデモ
%
% MATLAB/行列
%   intro       - MATLABの基本的な行列演算の紹介。
%   inverter    - 逆行列のデモ。
%   buckydem    - Buckminster Fuller geodesic domeの結合グラフ。
%   sparsity    - スパース性の度合いのデモ。
%   matmanip    - 行列操作。
%   eigmovie    - 対称固有算出処理過程の表示。
%   rrefmovie   - 行の階段型の処理過程の表示。
%   delsqdemo   - 種々の領域での有限差分ラプラス演算子。
%   sepdemo     - 有限要素のメッシュのセパレータ。
%   airfoil     - NASA airfoilのスパース行列の表示。
%   eigshow     - 行列の固有値のグラフィカルなデモ。
%
% MATLAB/数値
%   funfuns     - 他の関数を引数として使う関数のデモ。
%   fitdemo     - シンプレックスアルゴリズムを使った非線形カーブフィット。
%   sunspots    - FFT: 答えが11.08の場合の質問は？
%   e2pi        - 2次元のビジュアルな解法。e^piとpi^eではどちらが大きいか。
%   bench       - MATLABベンチマーク。
%   fftdemo     - 高速有限フーリエ変換。
%   census      - 2000年の米国の人口の予想。
%   spline2d    - 2次元のGINPUTとSPLINE。
%   lotkademo   - 常微分方程式の解法の例。
%   quaddemo    - 適応求積法
%   zerodemo    - fzeroを使ったゼロの検索。
%   fplotdemo   - 関数のプロット。
%   quake       - Loma Prieta地震。
%   qhulldemo   - 散布データの分類と内挿。
%   expmdemo1   - Pade 近似を使った行列指数。
%   expmdemo2   - Taylor 級数を使った行列指数。
%   expmdemo3   - 固有値と固有ベクトルを使った行列指数。
%
% MATLAB/可視化
%   graf2d      - 2次元プロット。MATLABでのXYプロット。
%   graf2d2     - 3次元プロット。MATLABでのXYZプロット。
%   grafcplx    - MATLABでの複素関数プロット。
%   lorenz      - Lorenz chaotic attractorの軌道のプロット。
%   imageext    - カラーマップのイメージ：カラーマップの種類の変更。
%   xpklein     - Kleinボトルのデモ。
%   vibes       - 振動のムービー：L-型膜の振動。
%   xpsound     - 音声の可視化：MATLABの音声機能。
%   imagedemo   - MATLABのイメージ機能のデモ。
%   penny       - pennyデータを使った種々の表示結果。
%   earthmap    - 地球の表示。
%   xfourier    - フーリエ変換のグラフィックデモ。
%   cplxdemo    - 複素数を変数とする関数表示。
%
% MATLAB/言語
%   xplang      - MATLAB言語の紹介。
%   hndlgraf    - Handle Graphicsのlineプロット。
%   graf3d      - Handle Graphicsのsurfaceプロット。
%   hndlaxis    - Handle Graphicsのaxes。
%   nesteddemo  - ネストされた関数の例。
%   anondemo    - Anonymous Function の例。
%
% MATLAB/微分方程式
%   odedemo     - ODE suite積分のデモ。
%   odeexamples - MATLAB ODE/DAE/BVP/PDE 例題のブラウザ。
% MATLAB/ODEs
%   ballode     - バウンドするボールのデモ。
%   brussode    - 化学反応のモデリングのスティッフな問題(Brusselator)。
%   burgersode  - Burgers 方程式を移動メッシュ化法を使って解く。
%   fem1ode     - 時変のマス行列をもつスティッフな問題。
%   fem2ode     - 不時変なマス行列をもつスティッフな問題。
%   hb1ode      - HindmarshとByrneのスティッフな問題1。
%   orbitode    - ORBITDEMOで使用する制限された3体問題。
%   rigidode    - 外力のない剛体のEuler方程式。
%   vdpode      - パラメータ化可能なvan der Pol方程式(大きいmuに対して
%                 スティッフ)。
% MATLAB/DAEs
%   hb1dae      - 保存則に従ったスティッフな DAE。
%   amp1dae     - 電気回路からのスティッフな DAE。
% MATLAB/Fully Implicit Differential Equations
%   iburgersode - Burgers 方程式をインプリシット常微分方程式(ODE)系として解く。
%   ihb1dae     - 保存則からのスティッフなインプリシット微分代数方程式(DAE)。
% MATLAB/DDEs
%   ddex1       - DDE23の例題1
%   ddex2       - DDE23の例題2
% MATLAB/BVPs   
%   twobvp      - 厳密な意味で2つの解をもつ BVP。
%   mat4bvp     - Mathieu の方程式の4番目の固有値の検出。
%   shockbvp    - 解が、x = 0 でショック層をもつ。
%   fsbvp       - 無限区間上での Falkner-Skan BVP。
%   emdenbvp    - Emden 方程式 - 特異項をもつ BVP。
%   threebvp    - 3点境界値問題
% MATLAB/PDEs   
%   pdex1       - PDEPEに対する例題1
%   pdex2       - PDEPEに対する例題2
%   pdex3       - PDEPEに対する例題3
%   pdex4       - PDEPEに対する例題4
%   pdex5       - PDEPEに対する例題5
%
% Extras/ギャラリ
%   knot        - 3次元の節点を囲む管。
%   quivdemo    - quiver関数のデモ。
%   klein1      - Kleinボトルの作成。
%   cruller     - crullerの作成。
%   tori4       - 4つの組み合わされた輪の作成。
%   spharm2     - 球面調和関数の作成。
%   modes       - L型の膜の12個のモードのプロット。
%   logo        - MATLAB L型膜のロゴの表示。
%
% Extras/ゲーム
%   fifteen     - スライディングパズル。
%   xpbombs     - マインスイーバゲーム。
%   life        - Conwayの人生ゲーム。
%   soma        - Somaキューブ。
%
% Extras/その他
%   truss       - 橋の曲げのアニメーション。
%   travel      - 巡回セールスマン問題。
%   spinner     - カラーの付いたラインの回転。
%   xpquad      - Superquadricsのプロットのデモ。
%   codec       - アルファベットの符号化/復号化。
%   xphide      - 運動中のオブジェクトの可視識別。
%   makevase    - 回転するsurfaceの作成とプロット。
%   wrldtrv     - 地球上の大円航行ルート。
%   logospin    - MATLABのロゴの回転のムービー。
%   crulspin    - crullerムービーの回転。
%   quatdemo    - Quaternion 回転。
%   chaingui    - 行列連鎖乗算最適化。
%
% General Demo/補助関数
%   cmdlnwin    - コマンドラインデモの実行のためのゲートウェイルーチン。
%   cmdlnbgn    - コマンドラインデモの設定。
%   cmdlnend    - コマンドラインデモの後のクリーンアップ。
%   finddemo    - 個々のToolboxで可能なデモの検索。
%
% MATLAB/補助関数
%   bucky       - Buckminster Fuller geodesic domeのグラフ。
%   peaks       - 2変数の関数の例題。
%   membrane    - MATLABのロゴの出力。
%
%
% 参考 ： SIMDEMOS


%   Copyright 1984-2004 The MathWorks, Inc. 
