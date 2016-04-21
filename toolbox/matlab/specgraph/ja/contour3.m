% CONTOUR3   3次元コンタープロット
% 
% CONTOUR3(...) は、Zレベルに対応するコンターが描画されること以外は、
% CONTOUR(...) と同じです。
%
% C = CONTOUR3(...) は、CONTOURC で記述され、CLABEL で使用されたように、
% コンター行列 C を出力します。
%
% [C,H] = CONTOUR3(...) は、PATCHオブジェクトのハンドル番号からなる
% 列ベクトル H を出力します。各オブジェクトの UserData プロパティは、
% 各コンターの標高値を含んでいます。
%
% 例題:
%      contour3(peaks)
%
% 参考：CONTOUR, CONTOURF, CLABEL, COLORBAR.


%   Clay M. Thompson 3-20-91, 8-18-95
%   Modified 1-17-92, LS
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:04:46 $
