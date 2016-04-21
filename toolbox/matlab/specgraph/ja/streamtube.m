% STREAMTUBE は、3次元のストリームチューブを描画します。
% 
% STREAMTUBE(X,Y,Z,U,V,W,STARTX,STARTY,STARTZ) は、ベクトルデータ U,V,W
% からストリームチューブを描画します。配列 X,Y,Z は、U,V,W の座標系を
% 定義するもので、単調関数で(MESHGRID で作成した)3次元格子構造である
% 必要があります。STARTX,STARTY,STARTZ は、チューブの中心で、ストリーム
% ラインの出発点を定義します。チューブの幅は、ベクトル場の正規化された
% Divergence に比例します。サーフェスを表すハンドル番号からなるベクトルが、
% (出発点に付き1つ)H に出力されます。通常、STREAMTUBE をコールする前に、
% DataAspectRatio を設定することをお勧めします。
% 
% STREAMTUBE(U,V,W,STARTX,STARTY,STARTZ) は、つぎのステートメントを
% 仮定しています。
% 
%         [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% ここで、[M,N,P] = SIZE(U) です。 
%   
% STREAMTUBE(VERTICES,X,Y,Z,DIVERGENCE) は、ストリームラインの頂点と 
% Divergence を前もって計算していると仮定します。VERTICES は、ストリーム
% ライン X,Y,Z のセル配列で、DIVERGENCE は、3次元は配列です。
%
% STREAMTUBE(VERTICES,DIVERGENCE) は、つぎのステートメントを仮定して
% います。
% 
%   [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% ここで、[M,N,P] = SIZE(DIVERGENCE) です。  
%
% STREAMTUBE(VERTICES,WIDTH) は、ベクトル WIDTH のセル配列を使って、
% チューブの幅を設定します。VERTICES と WIDTH の各対応する要素の大きさ
% は、同じでなければなりません。
%
% STREAMTUBE(VERTICES,WIDTH) は、スカラ WIDTH を使って、すべてのスト
% リームチューブの幅を一定にします。
%
% STREAMTUBE(VERTICES) は、自動的に幅を設定します。
%
% STREAMTUBE(...,[SCALE N]) は、SCALE を使って、チューブの幅を設定します。
% デフォルトは、SCALE = 1 です。ストリームチューブが出発点または Divergence
% を使って作成された場合は、SCALE = 0 は、自動的なスケーリングを行いません。
% N は、チューブの周りを設定する位置の数です。デフォルトは、N = 20です。
%
% STREAMTUBE(AX,...) は、GCAの代わりにAXにプロットします。
%
% H = STREAMTUBE(...)) は、SURFACE オブジェクトの(開始点ごとに1つの)ハンド
% ル番号のベクトルとして出力します。
%
% 例題 1:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      daspect([1 1 1])
%      h = streamtube(x,y,z,u,v,w,sx,sy,sz);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
%
% 例題 2:
%      load wind
%      [sx sy sz] = meshgrid(80, 20:10:50, 0:5:15);
%      verts = stream3(x,y,z,u,v,w,sx,sy,sz);
%      div = divergence(x,y,z,u,v,w);
%      daspect([1 1 1])
%      h = streamtube(verts,x,y,z,div);
%      axis tight
%      shading interp;
%      view(3);
%      camlight; lighting gouraud
% 
% 参考：DIVERGENCE, STREAMRIBBON, STREAMLINE, STREAM3.


%   Copyright 1984-2002 The MathWorks, Inc. 
