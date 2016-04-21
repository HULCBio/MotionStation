% ALPHAMAP - figureの AlphaMap プロパティを設定
%
% ALPHAMAP(MATRIX)     - カレントのFigureの AlphaMap プロパティを MATRIX
%                        に設定
% ALPHAMAP('default')  - AlphaMap にそのデフォルト値を設定
% ALPHAMAP('rampup')   - 不透明度を増加する方向に線形 Alphamap を作成
% ALPHAMAP('rampdown') - 不透明度を減少する方向に線形 Alphamap を作成
% ALPHAMAP('vup')      - 中心部から両端方向に線形に増加する Alphamap 
%                        の透明度を作成
% ALPHAMAP('vdown')    - 中心部から両端方向に線形に減少する Alphamap 
%                        の不透明度を作成
% ALPHAMAP('increase') - より不透明になる方向に Alphamap を変更
% ALPHAMAP('decrease') - より透明になる方向に Alphamap を変更
% ALPHAMAP('spin')     - カレントの Alphamap を回転
%
% ALPHAMAP(PARAM, LENGTH) - 新しいマップを作成するパラメータに対して、
%                           長さ LENGTH になるように変更します。
% ALPHAMAP(CHANGE, DELTA) - Alphamap を変更するパラメータに対して、
%                           DELTA をパラメータとして使用します。
%
% ALPHAMAP(FIGURE,PARAM) - FIGUREの AlphaMap を PARAMeter に設定
% ALPHAMAP(FIGURE,PARAM,LENGTH)
% ALPHAMAP(FIGURE,CHANGE)
% ALPHAMAP(FIGURE,CHANGE,DELTA)
%
% AMAP=ALPHAMAP         - カレント Alphamap を使用
% AMAP=ALPHAMAP(FIGURE) - Figureのカレント Alphamap を使用
% AMAP=ALPHAMAP(PARAM)  - プロパティの設定を行わないで、PARAM ベースに 
%                         Alphamap を出力する
%
% 参考：ALPHA, ALIM, COLORMAP.


% $Revision: 1.2.4.1 $ $Date: 2004/04/28 01:54:27 $
% Copyright 1984-2002 The MathWorks, Inc.
