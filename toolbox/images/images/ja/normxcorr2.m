% NORMXCORR2 正規化した2次元の相互相関
%
% C = NORMXCORR2(TEMPLATE,A) は、行列 TEMPLATEと Aの正規化した相互相関を
% 計算します。正規化が意味をもつためには、行列 A は、行列 TEMPLATE より
% 大きいサイズであることが必要です。TEMPLATE の値は、必ずしも、すべて同じ
% ではありません。結果の行列 C は、相関係数を含んでいて、その範囲は、
% -1.0から1.0です。
%
% クラスサポート
% -------------
% 入力行列は、クラス logical、uint8, uint16, double のいずれかです。
% 出力行列 C は、double です。
%
% 例題
% -------
%   T = .2*ones(11); % 暗いグレーバックグランド上に明るいグレーを加える
%   T(6,3:9) = .6;   
%   T(3:9,6) = .6;
%   BW = T>0.5;      % 黒のバックグランド上に白を加える
%   imshow(BW), title('Binary')
%   figure, imshow(T), title('Template')
%   % テンプレートTをオフセットする新しいイメージを作成
%   T_offset = .2*ones(21); 
%   offset = [3 5];  % 3行5列のシフト
%   T_offset( (1:size(T,1))+offset(1), (1:size(T,2))+offset(2) ) = T;
%   figure, imshow(T_offset), title('Offset Template')
%   
%   % 相互相関BWと、オフセットを回復するためのT_offset  
%   cc = normxcorr2(BW,T_offset); 
%   [max_cc, imax] = max(abs(cc(:)));
%   [ypeak, xpeak] = ind2sub(size(cc),imax(1));
%   corr_offset = [ (ypeak-size(T,1)) (xpeak-size(T,2)) ];
%   isequal(corr_offset,offset) % 1 は、オフセットが回復されたことを意味します
%
% 参考  CORRCOEF.


%   Copyright 1993-2002 The MathWorks, Inc.
