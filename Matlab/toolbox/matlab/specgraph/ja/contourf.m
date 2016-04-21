% CONTOURF   塗りつぶしたコンタープロット
% 
% CONTOURF(...) は、コンターが塗りつぶされること以外は、CONTOUR(...) と
% 同じです。指定したレベル以上のデータの領域が塗りつぶされます。指定した
% レベル以下のデータ領域は、ブランクのままか、低いレベルの領域によって
% 塗りつぶされます。データ内のNaNは、塗りつぶしたコンタープロット内で、
% 穴として表示されます。
%
% C = CONTOURF(...) は、CONTOURC で記述され、CLABEL で使用されたように、
% コンター行列 C を出力します。
%
% [C,H] = CONTOURF(...) は、CONTOURオブジェクトのハンドルHも出力します。
%
% 下位互換性
% CONTOURF('v6',...) は、MATLAB 6.5およびそれ以前のバージョンとの互換性
% のため、coutourグループオブジェクトの代わりにpatchオブジェクトを作成し
% ます。 
%
% 例題:
%      z=peaks; 
%      [c,h] = contourf(z); clabel(c,h), colorbar
%
% 参考：CONTOUR, CONTOUR3, CLABEL, COLORBAR.


%   Author: R. Pawlowicz (IOS)  rich@ios.bc.ca   12/14/94
%   Copyright 1984-2002 The MathWorks, Inc. 
