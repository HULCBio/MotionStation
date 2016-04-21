% CMPERMUTE    カラーマップ内のカラーの再配列
% [Y,NEWMAP] = CMPERMUTE(X,MAP) は、MAP 内のカラーをランダムに並び替えて
% 新しいカラーマップ NEWMAP を作成します。CMPERMUTE は、X の中の値を、イ
% ンデックスとカラーマップ間の対応を維持しながら変更し、その結果を Y に
% 出力します。イメージ Y とそれに関連するカラーマップ NEWMAP は、X と 
% MAP で作成したイメージと同じイメージを作成します。
% 
% [Y,NEWMAP] = CMPERMUTE(X,MAP,INDEX) は、順番を設定した行列(SORT の2番
% 目の出力引数)を使って、新しいカラーマップにカラーの順番を定義します。
% 
% たとえば、輝度を使って、カラーマップの順番を決めます。
% 
%   ntsc = rgb2ntsc(map);
%   [dum,index] = sort(ntsc(:,1));
%   [Y,newmap] = cmpermute(X,map,index);
% 
% クラスサポート
% -------------
% 入力イメージ X は、uint8、または、double のいずれのクラスもサポートし
% ています。Y は、X と同じクラスの配列として出力されます。
% 
% 例題
% -------
% 輝度を使って、カラーマップの順番を決めます。
%
%       load trees
%       ntsc = rgb2ntsc(map);
%       [dum,index] = sort(ntsc(:,1));
%       [Y,newmap] = cmpermute(X,map,index);
%       imshow(X,map), figure, imshow(Y,newmap)
%
% 参考：RANDPERM, SORT.



%   Copyright 1993-2002 The MathWorks, Inc.  
