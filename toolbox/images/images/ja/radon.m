% RADON   Radon 変換
%
% 関数 RADON は、設定した角度の半径方向にイメージ強度を投影する 
% Radon 変換を計算します。
%
% R = RADON(I,THETA) は、角度 THETA 度に対する強度イメージ I の Rad-
% on 変換を出力します。THETA がスカラの場合、結果 R は、THETA 度に対
% する Radon 変換を含む列ベクトルになります。THETA がベクトルの場
% 合、その要素に対して、1つのRadon 変換の結果を列とする行列になりま
% す。THETA を省略すると、デフォルトの0:179を使います。
%
% [R,Xp] = RADON(...) は、R の各行に対応する半径方向の座標(度)をベク
% トル Xp に出力します。
%
% クラスサポート
% -------------
% I は、double、logical、または、任意の整数クラスをサポートしています。
% 他のすべての入力、出力は、クラス double です。どの入力でもスパースに
% なりません。
%
% 注意
% ----
% Xp に出力される半径方向の座標は、x 軸に沿った値です。これは、x 軸
% から反時計周りに THETA 度回転した方向です。両方の軸の原点は、イ
% メージの中心ピクセルで、デフォルトでは、
%
%        floor((size(I)+1)/2)
%
% です。たとえば、20行30列の大きさのイメージでは、中心ピクセルは
% (10,15) です。
%
% 例題
% ----
%       I = zeros(100,100);
%       I(25:75, 25:75) = 1;
%       theta = 0:180;
%       [R,xp] = radon(I,theta);
%       imshow(theta,xp,R,[],'n')
%       xlabel('\theta (degrees)')
%       ylabel('x''')
%       colormap(hot), colorbar
%
% 参考：IRADON, PHANTOM



%   This number is sufficient to compute the projection at unit
%   intervals, even along the diagonal.
