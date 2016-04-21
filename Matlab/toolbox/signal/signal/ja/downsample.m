function y = downsample(x,N,varargin)
%DOWNSAMPLE 信号入力をダウンサンプリングします。
%   DOWNSAMPLE(X,N) は、すべてのN-番目のサンプルを最初のものとして、
%   出発することにより、入力信号Xのダウンサンプリングを行います。X が行列
%   である場合、ダウンサンプリングは、X の列に沿って行われます。
%
%   DOWNSAMPLE(X,N,PHASE) は、オプションのサンプルのオフセット
%   を指定します。PHASE は、[0, N-1]の範囲の整数である必要があります。
%
%   参考 UPSAMPLE, UPFIRDN, INTERP, DECIMATE, RESAMPLE.


y = updownsample(x,N,'Down',varargin{:});

% [EOF] 


%   Copyright 1988-2002 The MathWorks, Inc.
