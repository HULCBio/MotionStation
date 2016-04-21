% REDUCEPATCH   パッチの面の数の削減
%
% REDUCEPATCH(P, R) は、パッチ全体の形を保持したまま、パッチ P の面の
% 数を減らします。R は1以下の場合、オリジナルの面の一部分として解釈され
% ます。たとえば、R が0.2の場合は面の20%が保持されます。R が1より大き
% ければ、R は面のターゲット数になります。たとえば、Rが400の場合は、
% 面の数は400個の面が残るまで減らされます。patchが共有されていない頂点を
% 含む場合は、共有される頂点が面を減らす前に計算されます。パッチの面が
% 三角形でない場合は、面を減らす前に三角形にします。出力される面は、
% 常に三角形です。 
%
% NFV = REDUCEPATCH(P, R) は、削減された面と頂点の集合を出力しますが、
% パッチ Pの Faces プロパティと Vertices プロパティを設定しません。
% 構造体 NFV は削減後の面と頂点を含みます。
% 
% NFV = REDUCEPATCH(FV, R) は、構造体 FV から面と頂点を使用します。
% 
% REDUCEPATCH(P) または NFV = REDUCEPATCH(FV) は、.5の削減を仮定します。
%
% REDUCEPATCH(...,'fast') は、頂点がユニークで、共有された頂点を計算
% しないと仮定しています。
% 
% REDUCEPATCH(...,'verbose') は、計算の進行状況に連れ、コマンドウインドウ
% に状況を表すメッセージを表示します。
% 
% NFV = REDUCEPATCH(F, V, R) は、配列FおよびV内の面および頂点を使用します。
% 
% [NF、NV] = REDUCEPATCH(...) は、面と頂点を構造体の代わりに2つの配列に
% 出力します。
%
% 注意: 出力三角形の数は、特に入力の面が三角形でなかった場合は、削減値で
% 指定したものと正確に一致しません。
%
% 例題:
% 
%      [x y z v] = flow;
%      fv = isosurface(x, y, z, v, -3);
%      subplot(1,2,1)
%      p = patch(fv);
%      set(p, 'facecolor', [.5 .5 .5], 'EdgeColor', 'black');
%      daspect([1 1 1]); view(3); axis tight
%      title([num2str(length(get(p, 'faces'))) ' Faces'])
%      subplot(1,2,2)
%      p = patch(fv);
%      set(p, 'facecolor', [.5 .5 .5], 'EdgeColor', 'black');
%      daspect([1 1 1]); view(3); axis tight
%      reducepatch(p, .15) % 面の 15% を保持 
%      title([num2str(length(get(p, 'faces'))) ' Faces'])
%
% 参考：ISOSURFACE, ISOCAPS, ISONORMALS, SMOOTH3, SUBVOLUME,
%       REDUCEVOLUME.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:05:34 $
