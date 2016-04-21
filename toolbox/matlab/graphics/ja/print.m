% PRINT   Figureまたはモデルの印刷。イメージまたはM-ファイルとして
%         ディスクに保存
%
% 構文:
%   print 
% PRINTは、カレントのfigureをユーザのカレントのプリンタに送ります。プリ
% ント出力の大きさと形は、FigureのPaperPosiotn[mode]プロパティとユーザの
% PRINTOPT.Mファイルで指定したデフォルトのprintコマンドにより異なります。
% 
%   print -s
% 
% 上記と同じですが、カレントのSimulinkモデルを印刷します。
%
%   print -device -options 
% 
% オプションとしてプリントデバイス(tiffやPostScriptのような出力フォーマ
% ットや、プリンタに送られるものを制御するプリントドライバ)や、プリント
% されるファイルの種々の特性(解像度、プレビューのタイプ、印刷するFigure
% 等)を制御するオプションを指定できます。使用可能なデバイスとオプション
% を下記に示します。
%
%   print -device -options filename
% 
% ファイル名を指定した場合、MATLABはプリンタの代わりにファイルに出力しま
% す。PRINTは、ファイル拡張子を指定しなければ、適切なものを追加します。
%
%   print( ... )
% 
% 上記と同じですが、これは、PRINTをMATLABコマンドとしてではなく、MATLAB
% 関数として呼び出します。これらの違いは、括弧の付いた引数リストをもつか
% 否かです。任意の入力引数に対して変数を渡すことができます。特に、印刷す
% るfigureやモデルのハンドルやファイル名を渡すのに役立ちます。
% 
% 注意: 
% PRINTは、ResizeFcnプロパティをもったfigureを印刷する場合は、ワーニング
% を表示します。 ワーニングを回避するには、PaperPositionModeプロパティを
% 'auto'にするか、または、"PageSetup"ダイアログで、フィギュアのスクリー
% ンを合わせるように設定してください。
%
% バッチ処理:
% PRINTの関数形式を使うことができます。これは、バッチ印刷に有効です。
% たとえば、別のグラフを作成するのにforループを使ったり、ある配列に格納
% されている一連のファイル名を印刷することができます。
%
%     for i = 1:length(fnames)
%         print('-dpsc','-r200',fnames(i))
%     end
%            
% 印刷するウィンドウの指定
% 
%   -f<handle>   % 印刷するFigureのHandle Graphicsのハンドル
%   -s<name>     % 印刷用にオープンしているSimulinkモデル名
%   h            % PRINTの関数形式を使うときのFigureまたはモデルのハンドル
% 
% 例題:
% print -f2      % 両方のコマンド共、PRINTOPTで指定されたデフォルトの
% print( 2 )     % ドライバとオペレーティングシステムコマンドを使って、
%                  Figure 2を印刷します。
%
% print -svdp    % vdpという名前のオープンしているSimulinkモデルをプリント
%                  します。
%
% 出力ファイルの指定:
% <filename>     % コマンドラインの文字列
% '<filename>'   % PRINTの関数形式を使うときに渡される文字列
% 
% 例題:
%
%     print -deps foo
%     fn = 'foo'; print( gcf、'-deps'、fn )
% 
% 両者共ともカレントのfigureを、カレントの作業ディレクトリ内の'foo.eps'
% というファイルに保存します。EPSファイルは、Wordドキュメントや他のワー
% ドプロセッサに挿入することができます。
%
% 共通のデバイスドライバ
% 出力形式は、デバイスドライバ入力引数で指定されます。この引数は、'-d'か
% ら始まり、つぎのカテゴリのうちの1つに該当します。
% 
% Microsoft Windowsシステムのデバイスドライバオプション:
% 
%     -dwin      % figureをモノクロでカレントプリンタに送る
%     -dwinc     % figureをカラーでカレントプリンタに送る
%     -dmeta     % figureをMetafileフォーマットでクリップボード(または
%                  ファイル)に送る
%     -dbitmap   % figureをビットマップフォーマットでクリップボード
%                  (またはファイル)に送る
%     -dsetup    % Print Setupダイアログボックスを立ち上げるが、印刷は
%                  行わない
%     -v         % Verboseモードで、通常は表示されないPrintダイアログ
%                  ボックスを立ち上る
%
% MATLABに組み込まれているドライバ:
% 
%     -dps       % 白黒プリンタに対するPostScript
%     -dpsc      % カラープリンタに対するPostScript
%     -dps2      % Level 2の白黒プリンタに対するPostScript
%     -dpsc2     % Level 2のカラープリンタに対するPostScript
%
%     -deps      % Encapsulated PostScript 
%     -depsc     % Encapsulated Color PostScript
%     -deps2     % レベル2のEncapsulated PostScript
%     -depsc2    % レベル2のカラーEncapsulated PostScript
% 
%     -dhpgl     % Hewlett-Packard 7475A プロッタ互換のHPGL 
%     -dill      % Adobe Illustrator 88互換イラストレーションファイル
%     -djpeg<nn> % 品質レベルnnのJPEG イメージ(Figureウィンドウのみ、
%                  -looseを意味します)。たとえば、-djpeg90 が品質レベル
%                  90です。nnが省略されると、品質レベルのデフォルトは75
%                  です。
%     -dtiff     % packbits(lossless run-length encoding)圧縮を使った
%                  TIFF(Figureウィンドウのみ、-looseを意味します)
%     -dtiffnocompression 　　
%                % 圧縮を使わないTIFF (Figureウィンドウのみ、-looseを意
%                  味します)
%     -dpng      % Portable Network Graphic 24ビットトゥルーカラーイメー
%                  ジ(Figureウィンドウのみ、-looseを意味します)    
% 
% 他の出力形式は、MATLABが提供するGhostScriptアプリケーションを使うこと
% によって可能です。完全な出力形式のリストは、コマンド
% 'help private/ghostscript'を使って、GHOSTSCRIPTのオンラインヘルプを
% 参照してください。
% GhostScriptでサポートされているデバイスドライバの例を以下に示します。
% 
%     -dljet2p   % HP LaserJet IIP
%     -dljet3    % HP LaserJet III
%     -ddeskjet  % HP DeskJetとDeskJet Plus
%     -dcdj550   % HP Deskjet 550C
%     -dpaintjet % HP PaintJet color printer
%     -dpcx24b   % 24ビットカラーPCXファイルフォーマット、
%                  3種の8ビットplanes
%     -dppm      % Portable Pixmap (plain形式)
%
% 例題:
%     print -dwinc  % カレントのFigureをカラーでカレントのプリンタに
%                     印刷
%     print( h、'-djpeg'、'foo') % Figure/モデルh をfoo.jpgに印刷
%
% プリントオプション
% PostScriptとGhostScriptドライバでのみ使用されるオプションを以下に示し
% ます。
%     -loose     % FigureのPaperPositionをPostScript BoundingBoxとして使
%                  用します。
%     -append    % グラフをPostScriptファイルに上書きせずに追加します。
%     -tiff      % TIFFプレビューを追加します。EPSファイルのみ(-looseを
%                  意味します)
%     -cmyk      % RGBの代わりにCMYKカラーを使用します。
%     -adobecset % Adobe PostScript標準キャラクタセットエンコードを使用
%                  します。
%
% PostScript、GhostScript、Tiff、Jpegのオプション:
%     -r<number>  %インチあたりのドット数で表わす解像度。Simulinkのデフ
%                  ォルトは90で、TiffとJpegイメージ内のFigureとZbufferモ
%                  ードでの印刷のデフォルトは150です。それ以外は864です。
%                  スクリーンの解像度を指定するには、-r0を使用してくださ
%                  い。
% 
% 例題:
%     print -depsc -tiff -r300 matilda 
%
% カレントの Figure を300 dpiで TIFF プレビュー(Simulink モデルに対して 
% 72 dpi, figure に対して150 dpi )を使ってカラーEPSで matilda.eps に保存
% します。この TIFF プレビューは、matilda.eps が Wordドキュメント内に 
% Picture として挿入されれば表示されますが、Wordドキュメントが PostScript 
% プリンタで印刷された場合は、EPS が使用されます。
%
% figureウィンドウに対する他のオプション:
%     -Pprinter  % プリンタを指定。Windows と Unix で使用。
%     -noui      % UIコントロールオブジェクトを印刷しません
%     -painters  % 印刷のための描画は、Paintersモードで行われます
%     -zbuffer   % 印刷のための描画は、Z-Bufferモードで行われます
%     -opengl    % 印刷のための描画は、OpenGL モードで行われます。
% figureの印刷時のRendererの注意として、MATLABはスクリーン上と同じ
% Rendererを常に使うわけではありません。これは、効率性に依るものです。
% そのため、印刷された出力がこの理由によりスクリーン上と異なる場合が
% あります。このような場合に-zbuffer、または、-opengl を指定すると、
% スクリーンをエミュレートする出力を与えます。
%
% より詳細なヘルプは、MATLABコマンドラインでコマンド'doc print'とタイプ
% して、デバイスとオプションの完全なリストを見てください。印刷の詳細な情
% 報は、Using MATLAB Graphicsマニュアルを参照してください。
%
% 参考：PRINTOPT, PRINTDLG, ORIENT, IMWRITE, HGSAVE, SAVEAS.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.12.4.1 $  $Date: 2004/04/28 01:56:05 $

