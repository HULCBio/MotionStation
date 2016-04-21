% IMROTATE   イメージの回転
%
% B = IMROTATE(A,ANGLE,METHOD) は、設定した内挿法を使って、イメージ A 
% を反時計周りに ANGLE 度回転します。METHOD は、つぎの3つの中から選択
% できる文字列です。
%
%        'nearest'  (デフォルト) 最近傍法
%
%        'bilinear'              Bilinear 法
%
%        'bicubic'               Bicubic 法
%
% 引数 METHOD を省略すると、IMROTATE はデフォルトの 'nearest' を使いま
% す。イメージを時計周りに回転させるには、負の角度を設定してください。
%
% B = IMROTATE(A,ANGLE,METHOD,BBOX) は、イメージ A を ANGLE だけ回転さ
% せます。イメージを包む bounding ボックスは、引数 BBOX で設定され、
% 'loose'、または、'crop'のいずれかを設定することができます。BBOX が、
% 'loose'の場合、B は、回転したイメージ全体を包むので、一般には、A より
% 大きくなります。BBOX が、'crop'の場合、回転したイメージの中央部のみが
% 包まれ、A と同じサイズになります。引数 BBOX を省略すると、IMROTATE 
% は、デフォルトの 'loose' を使います。
%
% IMROTATE は、B の外側に不要な値として0を設定します。
%
% クラスサポート
% -------------
% 入力イメージは、logical、uint8、uint16、または、double のいずれの
% クラスもサポートしています。出力イメージは入力イメージと同じクラスに
% なります。
% 
% 例題
% ----
%        I = imread('ic.tif');
%        J = imrotate(I,-3,'bilinear','crop');
%        imshow(I), figure, imshow(J)
%
% 参考：IMCROP, IMRESIZE, IMTRANSFORM, TFORMARRAY



%   Copyright 1993-2002 The MathWorks, Inc.  
