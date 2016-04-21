% CYLINDER   円筒座標系の作成
%
% [X,Y,Z] = CYLINDER(R,N) は、ベクトル R の生成曲線に基づき、単位円筒を
% 作成します。
% ベクトル R は、円筒の単位高さに沿って等間隔に分布した点までの半径です。
% 円筒は、円周に N 点をもちます。SURF(X,Y,Z) は、円筒を表示します。
%
% [X,Y,Z] = CYLINDER(R) と [X,Y,Z] = CYLINDER のデフォルトは、N = 20 
% および R = [1 1] です。
%
% 出力引数を省略すると、SURF コマンドを使って円筒が表示され、何も出力
% されません。
%
% CYLINDER(AX,...) は、GCAの代わりにAXにプロットします。
%
% 参考：SPHERE, ELLIPSOID.


%   Clay M. Thompson 4-24-91, CBM 8-21-92.
%   Copyright 1984-2002 The MathWorks, Inc. 
