% 3次元グラフ
% 
% 基本的3次元グラフ
% plot3      - 3次元空間にラインと点をプロット
% mesh       - 3次元メッシュサーフェス
% surf       - 3次元色付きサーフェス
% fill3      - 塗りつぶした3次元多角形
% 
% カラーコントロール
% colormap   - カラールックアップテーブル
% caxis      - 擬似カラー軸のスケーリング
% shading    - カラーシェーディングモード
% hidden     - メッシュプロットの陰線処理
% brighten   - カラーマップの強度の変更
% colordef   - カラーのデフォルトの設定
% graymon    - グレイスケールモニタに対するグラフィックスのデフォルトの設定
%              
% ライティング
% surfl      - ライティングによる3次元サーフェスのプロット
% lighting   - ライティングモード
% material   - 物体反射モード
% specular   - 鏡面反射
% diffuse    - 拡散反射
% surfnorm   - サーフェスの法線
%
% カラーマップ
% hsv        - 色相-彩度-値によるカラーマップ
% hot        - 黒-赤-黄-白によるカラーマップ
% gray       - 線形グレイスケールのカラーマップ
% bone       - 青成分をもつグレイスケールのカラーマップ
% copper     - 線形copper-toneによるカラーマップ
% pink       - ピンクのパステルのカラーマップ
% white      - すべてが白色のカラーマップ
% flag       - 赤、白、青、黒に変化するカラーマップ
% lines      - ラインカラーをもつカラーマップ
% colorcube  - 拡張されたカラーキューブのカラーマップ
% vga        - Microsoft Windows用16色カラーマップ
% jet        - HSVの変形
% prism      - プリズムカラーマップ
% cool       - シアンとマジェンタの色調のカラーマップ
% autumn     - 赤と黄の色調のカラーマップ
% spring     - マジェンタと黄の色調のカラーマップ
% winter     - 青と緑の色調のカラーマップ
% summer     - 緑と黄の色調のカラーマップ
%
%
% 透明性
% alpha      - 透明度(alpha) モード
% alphamap   - 透明度(alpha) のルックアップテーブル
% alim       - 透明度(alpha) のスケーリング
%
% 軸の制御
% axis       - 軸のスケーリングと外観の制御
% zoom       - 2次元プロットのズームインとズームアウト
% grid       - グリッドライン
% box        - 軸のボックス
% hold       - カレントのグラフの保持
% axes       - 任意の位置にaxesを作成
% subplot    - 複数のaxesの作成
% daspect    - データの縦横比
% pbaspect   - プロットボックスの縦横比
% xlim       - X の範囲
% ylim       - Y の範囲
% zlim       - Z の範囲
%
% 視点の制御
% view       - 3次元グラフの視点の指定
% viewmtx    - 視点の変換行列
% rotate3d   - 3次元プロットの視点の対話的な回転
%
% カメラコントロール
% campos     - カメラの位置
% camtarget  - カメラのターゲット
% camva      - カメラの視点の角度
% camup      - カメラの上向きベクトル
% camproj    - カメラの投影
%
% 高水準カメラコントロール
% camorbit   - カメラの軌跡
% campan     - カメラをパン(回転)します
% camdolly   - カメラの移動
% camzoom    - カメラのズーム
% camroll    - カメラの回転
% camlookat  - 指定したオブジェクトを見るためにカメラとターゲットを移動
% cameramenu - 対話的なカメラの操作
%
% 高水準lightコントロール
% camlight   - lightオブジェクトの作成と位置の設定
% lightangle - lightオブジェクトの球面座標系の位置
%
% グラフの注釈
% title      - グラフのタイトル
% xlabel     - X軸のラベル
% ylabel     - Y軸のラベル
% zlabel     - Z軸のラベル
% text       - テキストの注釈
% gtext      - マウスを使ってテキストを付ける
% plotedit   - プロットの編集と注釈付けのためのツール
%
% ハードコピーと印刷
% print      - グラフやSimulinkシステムの印刷。グラフをM-ファイルに保存
% printopt   - プリンタのデフォルト
% orient     - 用紙の方向の設定
% vrml       - グラフィックスをVRML 2.0ファイルに保存
%
% 参考： GRAPH2D, SPECGRAPH.


%   Copyright 1984-2002 The MathWorks, Inc. 
