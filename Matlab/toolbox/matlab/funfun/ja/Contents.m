% 関数を引数とする関数とODEソルバ
%
% 最適化と根の算出
% fminbnd    - スカラでも範囲付き非線形関数の最小化
% fminsearch - Nelder-Mead直接サーチ法を使った多次元制約なし非線形最小化
% fzero      - スカラ非線形ゼロ点算出 
%
% 最適化オプションの取り扱い
% optimset   - 最適化OPTIONS構造体の作成/変更. 
% optimget   - OPTIONS構造体からの最適化パラメータの取得
%
% 数値積分(求積法).
% quad       - 低次の数値積分
% quadl      - 高次の数値積分
% dblquad    - 数値重積分
% triplequad - 三重積分の数値解
%
% プロット
% ezplot     - 関数のプロット
% ezplot3    - 3次元パラメトリックなカーブのプロット
% ezpolar    - 極座標プロット
% ezcontour  - コンタプロット
% ezcontourf - 塗りつぶしたコンタプロット
% ezmesh     - 3次元メッシュプロット.
% ezmeshc    - メッシュ/コンタプロット
% ezsurf     - 3次元カラー付きサーフェスプロット
% ezsurfc    - サーフェス/コンタプロット
% fplot      - 関数のプロット
%
% インライン関数オブジェクト
% inline     - INLINE関数オブジェクトの作成
% argnames   - 引数名
% formula    - 関数の型
% char       - INLINEオブジェクトをキャラクタ配列に変換
%
% 常微分方程式の解
% ODEs の初期値問題(スティッフかどうかがわからない場合は、まずODE45を行
% い、つぎにODE15Sを行ってください)
% ode45     - ノンスティッフな微分方程式の中次の解法
% ode23     - ノンスティッフな微分方程式の低次の解法
% ode113    - ノンスティッフな微分方程式の可変次数の解法
% ode23t    - わずかにスティッフな常微分方程式や微分代数方程式の台形法を
%             用いた解法
% ode15s    - スティッフな常微分方程式や、微分代数方程式の可変次数の解法
% ode23s    - スティッフな微分方程式の低次の解法
% ode23tb   - スティッフな微分方程式の低次の解法
%
% fully インプリシット ODEs/DAEs F(t,y,y')=0 に対する初期値問題ソルバ
% decic     - 矛盾のない初期条件の計算
% ode15i    - インプリシット ODEs または DAEs Index 1 を解きます。
%
% 遅れ微分方程式(DDE)に対する初期値問題ソルバ 
% dde23     - 定数遅れをもつ遅れ微分方程式(DDE)の解法)
%
% ODEに対する境界値問題ソルバ
% bvp4c     - 選点法による ODEs の2点境界値問題を解きます。
%
% 1次元偏微分方程式ソルバ
% pdepe     - 双曲線-楕円 PDEs の初期境界値問題を解きます。
% 
% オプションの取り扱い
% odeset    - ODE OPTIONS構造体の作成と変更
% odeget    - ODE OPTIONSパラメータの取得
% ddeset    - DDE OPTIONS構造体の作成と変更
% ddeget    - DDE OPTIONSパラメータの取得
% bvpset    - BVP OPTIONS構造体の作成と変更
% bvpget    - BVP OPTIONSパラメータの取得
%
% ODE関数の入出力関数.
% deval     - 微分方程式問題の解の計算
% odextend  - 微分方程式問題の解の拡張
% odeplot   - 時系列ODE出力関数
% odephas2  - 2次元位相平面ODE出力関数
% odephas3  - 3次元位相平面ODE出力関数
% odeprint  - ODE出力関数のコマンドウィンドウの印刷
% bvpinit   - BVP4C 用の初期推定値を作成
% pdeval    - PDEPEにより算出された解の内挿による計算
% odefile   - MATLAB Version 5 の ODE ファイルのシンタックス(古い形式)


%   Copyright 1984-2002 The MathWorks, Inc. 
