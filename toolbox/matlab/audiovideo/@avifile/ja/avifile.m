% AVIFILE   新しい AVI ファイルを作成
%
% AVIOBJ = AVIFILE(FILENAME) は、デフォルトパラメータ値をもつ AVIFILE 
% オブジェクト AVIOBJ を作成します。FILENAME が拡張子を含んでいない場合、
% '.avi' が使われます。AVIFILE によって開かれたファイルを閉じるには、
% AVIFILE/CLOSE を使います。すべての開かれたAVIファイルを閉じるには、
% "clear mex" を使ってください。
%
% AVIOBJ = AVIFILE(FILENAME,'PropertyName',VALUE,'PropertyName',VALUE,...)
% は、指定したプロパティ値をもつ AVIFILE オブジェクトを出力します。
%
% AVIFILE パラメータ
%
% FPS         - AVIムービー用の秒毎のフレーム。このパラメータは、ADDFRAME
%               を使用する前に設定されていなければなりません。デフォルト
%               は、15 fps です。
%
% COMPRESSION - 圧縮に用いる方法を指定する文字列です。UNIXでは、この値は
%               'None' でなければなりません。Windows用の利用可能なパラメータ
%               は、'Indeo3', 'Indeo5', 'Cinepak', 'MSVC', 'RLE', 'None'
%               のいずれかです。ユーザの圧縮法を使用する場合、値は codec 
%               ドキュメントで指定された4つのキャラクタコードを使います。
%               指定されたユーザの圧縮法が見つからない場合、ADDFRAME を
%               コールしている間にエラーになります。このパラメータは、
%               ADDFRAME を使用する前に設定されていなければなりません。
%               デフォルトは、Windowsで 'Indeo5'で、UNIXでは 'None' です。
%
% QUALITY      - 0から100の間の数。このパラメータは圧縮されていない
%                ムービーには影響しません。このパラメータは、ADDFRAME
%                を使用する前に設定されていなければなりません。高い値は、
%                高いビデオ画質でより大きなファイルサイズになり、低い
%                値は、低いビデオ画質で小さなファイルでより小さなファイル
%                サイズになります。デフォルトは75です。
%
% KEYFRAME     - 一時的な圧縮をサポートする圧縮法に対して、このパラメータ
%                は、単位時間(秒)あたりのキーフレーム数です。このパラメータ
%                は、ADDFRAME を使用する前に設定されていなければなりません。
%                デフォルトは毎秒2フレームです。
%
% COLORMAP     - インデックス付きAVIムービーに対して使用されるカラーマップ
%                を定義するM行3列の行列です。M は256より小さい数でなければ
%                なりません(Indeo 圧縮は236です)。このパラメータは、MATLAB
%                のムービーシンタックスとして ADDFRAME を使う以外では、
%                ADDFRAME がコールされる前に設定されていなければなりません。
%                デフォルトのカラーマップはありません。
%
% VIDEONAME    - ビデオストリーム用の記述名。このパラメータは、64キャラクタ
%                より小さくなければなりません。そして、ADDFRAME を使用
%                する前に設定する必要があります。デフォルトはファイル名です。
%
%
% AVIFILE プロパティは、MATLAB構造体シンタックスを用いて設定できます。
% 例えば、つぎのシンタックスを使って Quality プロパティに100を設定します。
%
%      aviobj = avifile(filename);
%      aviobj.Quality = 100;
%
% 
% 例題:
%
%      fig=figure;
%      set(fig,'DoubleBuffer','on');
%      set(gca,'xlim',[-80 80],'ylim',[-80 80],...
%      	   'NextPlot','replace','Visible','off')
%      mov = avifile('example.avi')
%      x = -pi:.1:pi;
%      radius = [0:length(x)];
%      for i=1:length(x)
%      	h = patch(sin(x)*radius(i),cos(x)*radius(i),[abs(cos(x(i))) 0 0]);
%      	set(h,'EraseMode','xor');
%      	F = getframe(gca);
%      	mov = addframe(mov,F);
%      end
%      mov = close(mov);
%
% 参考 : AVIFILE/ADDFRAME, AVIFILE/CLOSE, MOVIE2AVI.


%   Copyright 1984-2002 The MathWorks, Inc.
