% Image Processing Toolbox --- デモとサンプルイメージ
%                              
% デモ
%   dctdemo      - 2-D DCT によるイメージの圧縮のデモ
%   edgedemo     - エッジの検出のデモ
%   firdemo      - 2-D FIR フィルタの設計と適用のデモ
%   imadjdemo    - 強度イメージの調整とヒストグラムの均等化のデモ
%   landsatdemo  - ランドサットカラー合成のデモ
%   nrfiltdemo   - フィルタを使ったノイズ低減のデモ
%   qtdemo       - 4分割ツリー分解のデモ
%   roidemo      - 対象領域のみの処理を行うデモ
%
% 拡張された例題
% ipexindex        - 拡張された例題のインデックス
% ipexsegmicro     - 微細構造を検出するためのセグメント化
% ipexsegcell      - 細胞検出のためのセグメント化
% ipexsegwatershed - Watershed セグメント化
% ipexgranulometry - 星の大きさの分布
% ipexdeconvwnr    - Wiener フィルタによる明瞭化
% ipexdeconvreg    - 正則化による明瞭化
% ipexdeconvlucy   - Lucy-Richardson法による明瞭化
% ipexdeconvblind  - Blind deconnvolutionによる明瞭化
% ipextform        - イメージ変換ギャラリ
% ipexshear        - イメージの付加と共有
% ipexmri          - 3-D MRI スライス
% ipexconformal    - 等角写像 
% ipexnormxcorr2   - 正規化した相互相関
% ipexrotate       - 回転とスケールの回復
% ipexregaerial    - 航空写真のレジストレーション
%
% 拡張した例題での補助 M-ファイル
%   ipex001          - イメージの付加と共有の例題で使用      
%   ipex002          - イメージの付加と共有の例題で使用      
%   ipex003          - MRI スライスの例題で使用
%   ipex004          - 等角射影の例題で使用
%   ipex005          - 等角射影の例題で使用 
%   ipex006          - 等角射影の例題で使用
%
% サンプルMATファイル
%   imdemos.mat           - デモで使用するイメージ
%   trees.mat             - 風景図のイメージ
%   westconcordpoints.mat - 航空写真によるレジストレーションの例題で使用
%
% サンプルの JPEG イメージ
%   football.jpg
%   greens.jpg
%
% サンプルの PNG イメージ
%   concordorthophoto.png
%   concordaerial.png
%   westconcordorthophoto.png
%   westconcordaerial.png
%
% サンプルTIFFイメージ
%   afmsurf.tif
%   alumgrns.tif
%   autumn.tif  
%   bacteria.tif
%   blood1.tif  
%   board.tif
%   bonemarr.tif
%   cameraman.tif
%   canoe.tif   
%   cell.tif
%   circbw.tif
%   circles.tif 
%   circlesm.tif
%   debye1.tif  
%   eight.tif   
%   enamel.tif  
%   flowers.tif
%   forest.tif
%   ic.tif
%   kids.tif
%   lily.tif
%   logo.tif
%   m83.tif
%   moon.tif
%   mri.tif
%   ngc4024l.tif
%   ngc4024m.tif
%   ngc4024s.tif
%   paper1.tif
%   pearlite.tif
%   pout.tif
%   rice.tif
%   saturn.tif
%   shadow.tif
%   shot1.tif
%   spine.tif
%   testpat1.tif
%   testpat2.tif
%   text.tif
%   tire.tif
%   tissue1.tif
%   trees.tif
%
% サンプルのランドサットイメージ
%   littlecoriver.lan
%   mississippi.lan
%   montana.lan
%   paris.lan
%   rio.lan
%   tokyo.lan
%
% Photo credits
%   afmsurf, alumgrns, bacteria, blood1, bonemarr, circles, circlesm,
%   debye1, enamel, flowers, ic, lily, ngc4024l, ngc4024m, ngc4024s,
%   pearlite, rice, saturn, shot1, testpat1, testpat2, text, tire, tissue1:
%
%     Copyright J. C. Russ, The Image Processing Handbook, 
%     Third Edition, 1998, CRC Press, Boca Raton, ISBN
%     0-8493-2532-3.  Used with permission.
%
%   moon:
%
%     Copyright Michael Myers.  Used with permission.
%
%   cameraman:
%
%     Copyright Massachusetts Institute of Technology.  Used with
%     permission.
%
%   trees:
%
%     Trees with a View, watercolor and ink on paper, copyright Susan
%     Cohen.  Used with permission. 
%
%   forest:
%
%     Photograph of Carmanah Ancient Forest, British Columbia, Canada,
%     courtesy of Susan Cohen. 
%
%   circuit:
%
%     Micrograph of 16-bit A/D converter circuit, courtesy of Steve
%     Decker and Shujaat Nadeem, MIT, 1993. 
%
%   m83:
%
%     M83 spiral galaxy astronomical image courtesy of Anglo-Australian
%     Observatory, photography by David Malin. 
%
%   cell:
%
%     Cancer cell from a rat's prostate, courtesy of Alan W. Partin, M.D,
%     Ph.D., Johns Hopkins University School of Medicine.
%
%   board:
%
%     Computer circuit board, courtesy of Alexander V. Panasyuk,
%     Ph.D., Harvard-Smithsonian Center for Astrophysics.
%
%   LAN files:
%
%     Permission to use Landsat TM data sets provided by Space Imaging,
%     LLC, Denver, Colorado.
%
%   concordorthophoto and westconcordorthophoto:
%
%     Orthoregistered photographs courtesy of Massachusetts Executive Office
%     of Environmental Affairs, MassGIS.
%
%   concordaerial and westconcordaerial:
%
%     Visible color aerial photographs courtesy of mPower3/Emerge.



%   Copyright 1993-2002 The MathWorks, Inc.  
