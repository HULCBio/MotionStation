% FRAME2IM   ムービーフレームをインデックス付きイメージに変換
%
% [X,MAP] = FRAME2IM(F) は、単一のムービーフレーム F を、インデックス付き
% イメージ X と、関連するカラーマップ MAP に変換します。ムービーフレームは、
% GETFRAME や IM2FRAME から作成されます。フレームがトゥルーカラーの場合、
% MAP は空行列になります。
%
% 参考：IM2FRAME, MOVIE, CAPTURE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/04/28 02:05:10 $
%   Built-in function.
