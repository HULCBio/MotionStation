% GHOSTSCRIPT   PostScriptファイルを他の形式に変換
% Ghostscriptは、MATLABと共に提供されるサードパーティのアプリケーションです。G-
% hostscript自身の詳細な情報については、MATLABをインストールしているところのファ
% イルghoscript/gs.rightsを参照してください。
%
% PRINTコマンドは、入力引数としてデバイスドライバを指定します。テンポラリのPos-
% tScriptファイルを指定するこれらの引数のいくつかが作成され、Ghostscriptによって
% 他の形式に変換されます。結果のファイルは、出力デバイスに送られるか、または、
% PRINTコマンドによって名付けられたファイルになります。
%
% 以下のデバイスは Ghostscriptを使用し、すべてのプラットフォームでサポートされて
% います。
% 
%    -dlaserjet - HP LaserJet
%    -dljetplus - HP LaserJet+
%    -dljet2p   - HP LaserJet IIP
%    -dljet3    - HP LaserJet III
%    -ddeskjet  - HP DeskJet and DeskJet Plus
%    -ddjet500  - HP Deskjet 500
%    -dcdjmono  - HP DeskJet 500C 黒色印刷のみ
%    -dpaintjet - HP PaintJet カラープリンタ
%    -dpjxl     - HP PaintJet XL カラープリンタ
%    -dpjetxl   - HP PaintJet XL カラープリンタ
%    -dbj10e    - Canon BubbleJet BJ10e
%    -dbj200    - Canon BubbleJet BJ200
%    -dbjc600   - Canon Color BubbleJet BJC-600 および BJC-4000
%    -dln03     - DEC LN03 プリンタ
%    -depson    - Epson互換ドットマトリックスプリンタ (9ピンまたは24ピン)
%    -depsonc   - Epson LQ-2550 およびFujitsu 3400/2400/1200
%    -deps9high - Epson互換9ビンインタリーブライン(3階調)
%    -dibmpro   - IBM 9-pin Proprinter
%
% 以下のデバイスは Ghostscriptを使用し、UNIXプラットフォームでのみサポートされて
% います。
% 
%    -dcdjcolor - HP DeskJet 500C 24ビット/ピクセルカラー付き高品質カラー(Floyd-
%                 Steinberg)ディザリング
%    -dcdj500   - HP DeskJet 500C
%    -dcdj550   - HP Deskjet 550C
%    -dpjxl300  - HP PaintJet XL300 カラープリンタ;
%    -ddnj650c  - HP DesignJet 650C
%
% つぎの形式は、イメージフォーマットなので、常にディスク上のファイルとして残りま
% す。PRINTコマンドで名前を指定しない場合、デフォルトの名前が使用され、コマンド
% ラインにエコーされます。
% 
%    -dbmp256   - 8ビット(256色) .BMPファイル形式
%    -dbmp16m   - 24ビット.BMPファイル形式
%    -dpcxmono  - Monochrome PCXファイル形式
%    -dpcx16    - 旧式カラーPCXファイル形式(EGA/VGA、16色)
%    -dpcx256   - 新式カラーPCXファイル形式(256色)
%    -dpcx24b   - 24ビットカラーPCXファイル形式、3種の8-bit planes
%    -dpbm      - Portable Bitmap (plain形式)
%    -dpbmraw   - Portable Bitmap (raw形式)
%    -dpgm      - Portable Graymap (plain形式)
%    -dpgmraw   - Portable Graymap (raw形式)
%    -dppm      - Portable Pixmap (plain形式)
%    -dppmraw   - Portable Pixmap (raw形式)
%



%   $Revision: 1.4 $  $Date: 2002/06/17 13:33:32 $
%   Copyright 1984-2002 The MathWorks, Inc. 
