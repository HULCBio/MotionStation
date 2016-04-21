% GETFRAME   ムービーフレームの取り出し
% 
% GETFRAME は、ムービーフレームを出力します。フレームは、カレント軸の
% スナップショットです。GETFRAME は、MOVIEを使ってプレイバックするための
% ムービー配列を集めるために、FORループ内に置かれます。たとえば、
%
%    for j = 1:n
%       plot_command
%       M(j) = getframe;
%    end
%    movie(M)
%
% GETFRAME(H) は、H がfigureまたはaxisのハンドル番号のとき、オブジェクト 
% H からフレームを取り出します。
% GETFRAME(H,RECT) は、ビットマップのコピーをするために、オブジェクト 
% H の左下隅から、ピクセル単位で長方形を指定します。
%
% F = GETFRAME(...) は"cdata"と "colormap" のフィールドをもつ構造体の
% ムービーフレームを出力します。イメージデータは、uint8の行列で、colormap
% は倍精度の行列として定義されます。F.cdataは、高さ-幅-3で、F.colormapは
% TrueColorグラフィックを利用できるシステムでは空行列になります。たとえば:
% 
%    getframe(gcf);
%    colormap(f.colormap);
%    image(f.cdata);
%
% 参考：MOVIE, MOVIEIN, IMAGE, IM2FRAME, FRAME2IM.


%   Copyright 1984-2002 The MathWorks, Inc. 
