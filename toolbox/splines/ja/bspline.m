% BSPLINE   B-スプラインとその多項式の構成要素をプロット
%
% BSPLINE(T) は、節点列 T からなるB-スプラインとともに、それを構成する
% 多項式要素をプロットします。
%
% BSPLINE(T,WINDOW) は、指定された WINDOW 内にプロットした後、一時停止
% します。
%
% PP = BSPLINE(T) は、プロットは行いませんが、指定のB-スプラインのpp-型を
% 出力します。すなわち、pp = fn2fm(spmak(t,1),'pp') と同じ結果を与えます。
%
% 参考 : BSPLIDEM, BSPLIGUI, SPMAK


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
