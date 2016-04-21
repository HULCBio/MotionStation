% PDEPLOT   PDE Toolbox のプロット関数
%
% H = PDEPLOT(P,E,T,P1,V1,...) は、節点行列 P､エッジ行列 E、三角形行列 
% T で記述されるメッシュ上で定義された PDE の解の関数を表示します。描画
% される axes オブジェクトのハンドル番号は、オプションの出力引数 H に出
% 力されます。
%
% 有効なプロパティ/値の組合わせを以下に示します。
%
%     プロパティ      値/{デフォルト}
%     ----------------------------------------------------------------
%     xydata          データ (たとえば、u, abs(c*grad u))
%     xystyle         off | flat | {interp} |
%     contour         {off} | on
%     zdata           データ
%     zstyle          off | {continuous} | discontinuous
%     flowdata        データ
%     flowstyle       off | {arrow}
%     colormap        カラーマップ名{'cool'}またはカラー行列
%     xygrid          {off} | on
%     gridparam       [tn; a2; a3]三角形のインデックスと補間パラメータを
%                     高速化のためにtri2gridに渡す
%     mesh            {off} | on
%     colorbar        off | {on}
%     title           文字列{''}
%     levels          コンターレベル数またはレベルを設定しているベクトル
%                     {10}
%
% 参考   PDECONT, PDEGPLOT, PDEMESH, PDESURF



%       Copyright 1994-2001 The MathWorks, Inc.
