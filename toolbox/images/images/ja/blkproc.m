% BLKPROC   イメージに対するブロック処理の実行
% B = BLKPROC(A,[M N],FUN) は、イメージ A をそれぞれ M 行 N 列のブロック
% に明瞭に分割し、その個々に関数 FUN を適用することで、イメージ A を処理
% します。この場合、必要に応じて、A にゼロを付加します。FUN は、インライ
% ン関数、関数名を含む文字列、または、方程式を含む文字列でも構いません。
% FUNは、M 行 N 列のブロック X 上で機能し、行列、ベクトル、スカラのいず
% れかであるYを出力します。
% 
%    Y = FUN(X)
% 
% BLKPROC は、Y が X と同じ大きさである必要はありません。しかし、Y が X 
% と同じ大きさの場合のみ、B は A と同じ大きさになります。
% 
% B = BLKPROC(A,[MN],FUN,P1,P2,...) は、付加的なパラメータ P1,P2,...,を 
% FUN に渡します。
% 
% B = BLKPROC(A,[MN],[MBORDERNBORDER],FUN,...) は、ブロック周辺の重なり
% 状態を定義します。BLKPROC は、オリジナルの M 行 N 列を上と下方向に M-
% BORDER、左と右方向に NBORDER だけ拡張し、結果、(M+2*MBORDER) 行 (N+2
% *NBORDER) 列の大きさになります。BLKPROC は、必要な場合には A の周囲に
% ゼロを付加します。FUN は、拡張したブロック上で機能します。
% 
% B = BLKPROC(A,'indexed',...) は、A のクラスが、logical、uint8、または、
% uint16 である場合には0を、A のクラスが double である場合には1を付加
% して、A をインデックス付きイメージとして処理します。
% 
% クラスサポート
% -------------
% 入力イメージ A は、FUN がサポートするクラスであることが必要です。B の
% クラスは、FUN から出力されるクラスに依存します。
% 
% 例題
% -------
% つぎの例題は、8行8列のブロック内のピクセルに、それらの標準偏差を設定す
% るために BLKPROC を使います。
%  
%  I = imread('alumgrns.tif');
%  I2 = blkproc(I,[8 8],'std2(x)*ones(size(x))');
%  imshow(I)
%  figure, imshow(I2,[])
% 
% 参考：COLFILT, FUNCTION_HANDLE, NLFILTER, INLINE.



%   Copyright 1993-2002 The MathWorks, Inc.
