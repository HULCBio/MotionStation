% IMTRANSFORM  2 次元空間変換をイメージに適用
%
% B = IMTRANSFORM(A,TFORM) は、TFORM で定義した2次元空間変換に従って、イ
% メージ A を変換します。TFORM は、MAKETFORM、または、CP2TFORM で出力され
% るtform 型です。ndims(A) > 2 の場合、たとえば、RGB イメージの場合、同じ
% 2次元変換が、より高い次元に沿って、すべての2次元平面に自動的に適用され
% ます。
%
% このシンタックスを使用する場合、IMTRANSFORMは、変換されたイメージを、
% できるだけ、視覚化するために、出力イメージの原点を自動的にシフトします。
% イメージをレジストレーションするために、IMTRANSFORMを使用している場合、
% このシンタックスは、期待する結果を与えないでしょう。'XData' および 'YData'
% を明示的に設定したい場合があるかもしれません。例題3と同様に、'XData' と 
% 'YData'についての下記の記述を参照してください。
%
% B = IMTRANSFORM(A,TFORM,INTERP) は、使用する内挿の型を設定できます。
% INTERP は、文字列 'nearest', 'bilinear', 'bicubic' のいずれかを設定で
% きます。また、INTERP は、MAKEERESAMPLER により出力される構造体 RESAM-
% PLER でも構いません。このオプションは、リサンプリングの方法をよりコン
% トロールするものです。INTERP のデフォルト値は、'bilinear'です。
%
% [B,XDATA,YDATA] = IMTRANSFORM(...) は、出力 X-Y 平面に出力イメージ B 
% の位置を出力します。XDATA と YDATA は、2次元ベクトルです。XDATA の要
% 素は、B の最初の列と最後の列の x 座標を指定します。YDATA の要素は、B 
% の最初の行と最後の行の y 座標を指定します。通常、IMTRANSFORM は、イメ
% ージ A を変換したものを B がすべて含むように、XDATA と YDATA を自動的
% に計算します。しかし、下に示すように、この自動的な計算が無視される場合
% があります。
%
% [B,XDATA,YDATA] = IMTRANSFORM(...,PARAM1,VAL1,PARAM2,VAL2,...) は、空
% 間的な変換の種々の面をコントロールするパラメータを設定します。パラメ
% ータ名は、省略することもでき、大文字、小文字の区別も行いません。
%
% パラメータには、つぎのものが含まれます。
%
%   'UData'      2要素の実数ベクトル
%   'VData'      2要素の実数ベクトル
%                'UData' と 'VData' は、2次元の入力空間 U-V の中のイメ
%                ージ A の空間的な位置を指定します。'UData'の2要素は、
%                A の最初の列と最後の列の u 座標(水平方向)を指定します。
%                'VData' の2要素は、A の最初の行と最後の行の v 座標(垂
%                直方向)を指定します。
%
%                'UData' と 'VData' のデフォルト値は、[1 size(A,2)] と 
%                [1 size(A,1)] です。
%
%   'XData'      2要素の実数ベクトル
%   'YData'      2要素の実数ベクトル
%                'XData' と 'YData' は、2次元出力空間 X-Y の中の出力イメ
%                ージ B の空間的な位置を指定します。'XData' の2つの要素
%                は、B の最初の列と最後の列の x 座標(水平方向)を指定しま
%                す。'YData' の要素は、B の最初の行と最後の行の y 座標
%                (垂直方向)を指定します。
%
%                'XData' と 'YData' が設定されていない場合、IMTRANSFORM 
%                は、変換された出力イメージ全体を含むように、自動的に計
%                算されます。
%
%   'XYScale'    1、または、2要素の実数ベクトル
%                'XYScale' の最初の要素は、X-Y 空間での各出力ピクセルの
%                幅を設定します。(存在すれば)2番目の要素は、各出力ピクセ
%                ルの高さを設定します。'XYScale' が、1要素のみの場合、同
%                じ値が、幅と高さに使われます。
%
%                'XYScale' が、設定されていなく、'Size' が設定されている
%                場合、'XYScale' は、'Size', 'XData', 'YData' から計算され
%                ます。'XYScale'も'Size' も設定されていない場合、入力ピク
%                セルのスケールは、'XYScale' 用に使われます。
%
%   'Size'       非負の整数から構成される2要素ベクトル
%                'Size' は、出力イメージ B の行数と列数を設定します。高
%                次元の場合、B のサイズは、A のサイズから直接引き出され
%                ます。言い換えれば、size(B,k) は、k>2 の場合、size(A,k) 
%                と等価です。
%                
%                'Size' が設定されていない場合、'XData', 'YData', 'XYScale'
%                 から計算されます。
%
%   'FillValues' 1つまたは、いくつかのフル値を含んだ配列。
%                フル値は、入力イメージと対応する変換された位置が、入力
%                イメージ境界の外に完全に移動する場合に、出力ピクセルに
%                対して使われます。A が2次元の場合、'FillValues' は、ス
%                カラです。しかし、A の次元は、2より高くなる場合、'Fill-
%                Values' は、つぎの制約を満足する配列のサイズになります。
%                size(fill_values,k) は、size(A,k+2)、または、1と等しく
%                なります。たとえば、A が、200 x 200 x 3 の uint8 の RGB 
%                イメージの場合、'FillValues' に対して可能な値は、つぎの
%                ものです。
%
%                    0                 - フル値付黒
%                    [0;0;0]           - フル値付黒
%                    255               - フル値付白
%                    [255;255;255]     - フル値付白
%                    [0;0;255]         - フル値付青
%                    [255;255;0]       - フル値付青
%
%                A が、サイズ 200 x 200 x 3 x 10 の 4 次元配列の場合、
%                'FillValues' は、1×10, 3×1, 3×10 のスカラに
%                なります。
%
% 注意
% -----
%   - 'XData' と 'YData' を使って、B に対する出力空間の位置を指定してい
%     ない場合、IMTRANSFORM は、関数 FINDBOUNDS を使って、自動的に計算
%     します。いくつかの一般的に使われる変換、アフィン変換や射影変換に
%     対して、フォワードマッピングは計算が容易で、FINDBOUND は高速にな
%     ります。フォワードマッピングを行わない変換、たとえば、CP2TFORM 
%     によって計算される多項式変換に対して、FINDBOUNDS は、かなりの時間
%     を要します。このような変換に、'XData' や 'YData' を直接設定できる
%     場合、IMTRANSFORM は、かなり高速になります。
%
%   - FINDBOUNDS を使った、'XData' と 'YData' の自動的な算出は、変換さ
%     れた入力イメージのすべてのピクセルを完全に含むことが、すべてのク
%     ラスで保証されていません。
%
%   - 出力値 XDATA と YDATA は、入力 'XData と 'YData' パラメータと厳
%     密には一致しません。これは、整数、または、行と列、または、'XData',
%    'YData', 'XYScale', 'Size' が、整合性が保たれていないか、のいずれ
%     かに原因しています。いずれかの場合、XDATA と YDATA の最初の要素
%     は、'XData' と 'YData' の最初の要素と、各々、必ず等しくなります。
%     XDATA と YDATA の2番目の要素だけが、異なる可能性があります。
%
%   - IMTRANSFORM は、変換 TFORM に対して、空間座標の表現です。特に、変
%     換の最初の次元は、水平方向、または、x 座標で、2番目の次元は、垂直
%     方向、または、y 座標です。これは、MATLAB 配列のサブスクリプテング
%     での方法と逆であることに注意してください。
%
%   - TFORM は、IMTRANSFORM と共に使われる2次元変換です。任意の次元配列
%     の変換に関しては、TFORMARRAY を参照してください。
%
% クラスサポート
% -------------
% A は、任意の非スパース数値クラスで、実数、または、複素数です。A は、
% logical になることもできます。B のクラスは、A のクラスと同じです。
%
% 例題 1
%   --------
% 強度イメージに水平的なズレを適用します。
%
%       I = imread('cameraman.tif');
%       tform = maketform('affine',[1 0 0; .5 1 0; 0 0 1]);
%       J = imtransform(I,tform);
%       imshow(I), figure, imshow(J)
%
% 例題 2
%   --------
% 射影変換は、正方形を四辺形にマッピングします。この例題で、入力座標系
% を入力イメージが単位正方形を満たすように設定し、その後、頂点 (0 0), 
% (1 0), (1 1), (0 1) をもつ四辺形を、頂点  (-4 2), (-8 -3), (-3 -5), 
% (6 3) をもつ四辺形に変換します。グレーを使って、フル作業を行い、双キュ
% ービック補間を使用しています。出力の大きさは、入力の大きさと同じにして
% います。
%
%       I = imread('cameraman.tif');
%       udata = [0 1];  vdata = [0 1];  % 入力の座標系
%       tform = maketform('projective',[ 0 0;  1  0;  1  1; 0 1],...
%                                      [-4 2; -8 -3; -3 -5; 6 3]);
%       [B,xdata,ydata] = imtransform(I,tform,'bicubic','udata',udata,...
%                                                       'vdata',vdata,...
%                                                       'size',size(I),...
%                                                       'fill',128);
%       subplot(1,2,1), imshow(udata,vdata,I), axis on
%       subplot(1,2,2), imshow(xdata,ydata,B), axis on
%
% 例題 3
%   --------
% 航空機の写真をorthophotoに表示します。
%  
%       unregistered = imread('westconcordaerial.png');
%       figure, imshow(unregistered)
%       figure, imshow('westconcordorthophoto.png')
%       load westconcordpoints % load some points that were already picked     
%       t_concord = cp2tform(input_points,base_points,'projective');
%       info = imfinfo('westconcordorthophoto.png');
%       registered = imtransform(unregistered,t_concord,...
%                                'XData',[1 info.Width], 'YData',[1 info.Height]);
%       figure, imshow(registered)           
%
% 参考： CP2TFORM, IMRESIZE, IMROTATE, MAKETFORM, MAKERESAMPLER, TFORMARRAY.



%   Copyright 1993-2002 The MathWorks, Inc.
