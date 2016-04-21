% BFITOPEN は、Data Statistics、または、Basic Fitting GUI のいずれかを、
% オープン、または、再オープンします。
% 
% [HANDLES,NAMES,XSTATS,YSTATS,XCHECK,YCHECK] = BFITOPEN(FIGHANDLE,'ds')
% は、DataStat GUI 用のappdata とフィギュアウィンドウを設定します。HAN-
% DLES と NAMES は、BFITGETDATA から得られます。XSTATS と YSTATS は、B-
% FITCOMPUTEDATASTATS から得られます。XCHECK と YCHECK は、チェックボッ
% クスが、GUI の中でチェックされているか、否かを指示する5要素(論理値、0、
% または、1)からなる行ベクトルです。
%
% [HANDLES,NAMES,AXESOPEN,FITSCHECKED,BFINFO,] = BFITOPEN(FIGHANDLE,'bf') 
% は、Basic Fitting GUI 用のappdata とフィギュアウィンドウを設定します。
% HANDLES と NAMES は、BFITGETDATA から得られます。??? は、FUI に書き込
% むための他の引数です。

% $Revision: 1.5 $ $Date: 2002/06/17 13:32:32 $
%   Copyright 1984-2002 The MathWorks, Inc.
