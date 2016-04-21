function y = upsample(x,N,varargin)
%UPSAMPLE 信号入力をアンプサンプリングします。
%   UPSAMPLE(X,N) は、入力サンプルの間にN-1のゼロ点を挿入することに
%   よって、入力信号X をアップサンプリングします。 
%   X は、ベクトル、あるいは、(1列につき1シグナルをもつ)信号行列
%   のいずれかです。
%
%   UPSAMPLE(X,N,PHASE) は、オプションのサンプルオフセットを
%   指定します。PHASE は、[0, N-1]の範囲の整数である必要があります。
%
%   参考: DOWNSAMPLE, UPFIRDN, INTERP, DECIMATE, RESAMPLE.

y = updownsample(x,N,'Up',varargin{:});

% [EOF] 


%   Copyright 1988-2002 The MathWorks, Inc.
