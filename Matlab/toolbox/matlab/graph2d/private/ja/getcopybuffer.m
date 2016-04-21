function [copyBufferFig, copyBufferAx] = getcopybuffer(varargin)
%GETCOPYBUFFER
%   [copyBufferFig, copyBufferAx] = getcopybuffer
%   は、スクライブコピーバッファ figureとaxisを出力します。
%   すでにない場合は、作成します。
%
%   [copyBufferFig, copyBufferAx] = getcopybuffer('noforce')
%   は、コピーバッファ figureが存在しない場合でも、作成
%   しません。

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/06/17 13:32:30 $
