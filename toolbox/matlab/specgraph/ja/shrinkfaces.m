% SHRINKFACES   パッチの面のサイズの削減
%
% SHRINKFACES(P, SF) は、パッチ Pの面の面積を縮小係数 SF を基に縮小し
% ます。SF が0.6の場合、各々の面は元の面積の60%に縮小されます。パッチが
% 共有されている頂点を含む場合、削減する前に、頂点が共有しないように
% 作成されます。
% 
% NFV = SHRINKFACES(P, SF) は、面と頂点を出力しますが、パッチ Pの Faces
% プロパティと Vertices プロパティは設定しません。構造体 NFV は、新規の
% 面および頂点を含みます。
% 
% NFV = SHRINKFACES(FV, SF) は、構造体 FV から面と頂点を使用します。
%
% SHRINKFACES(P) または SHRINKFACES(FV) は、縮小係数を.3と仮定します。
% 
% NFV = SHRINKFACES(F, V, SF) は、配列 F および V 内の面および頂点を
% 使用します。
% 
% [NF, NV] = SHRINKFACES(...) は、構造体の代わりに2つの配列内の面および
% 頂点を出力します。
% 
% 例題:
%      [x y z v] = flow;
%      [x y z v] = reducevolume(x,y,z,v, 2);
%      fv = isosurface(x, y, z, v, -3);
%      subplot(1,2,1)
%      p = patch(fv);
%      set(p, 'facecolor', [.5 .5 .5], 'EdgeColor', 'black');
%      daspect([1 1 1]); view(3); axis tight
%      title('Original')
%      subplot(1,2,2)
%      p = patch(shrinkfaces(fv, .2)); % オリジナルの 20% まで面を削減
%      set(p, 'facecolor', [.5 .5 .5], 'EdgeColor', 'black');
%      daspect([1 1 1]); view(3); axis tight
%      title('After Shrinking')
%   
% 参考：ISOSURFACE, ISONORMALS, ISOCAPS, SMOOTH3, SUBVOLUME, 
%       REDUCEVOLUME, REDUCEPATCH.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:06:12 $
