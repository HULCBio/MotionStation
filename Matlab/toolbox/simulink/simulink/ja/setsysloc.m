% SETSYSLOC   システムの位置を設定
%
% SETSYSLOC(System) は、System の位置をスクリーンの左上隅に設定します。
% また、System 内に存在するすべてのサブシステムの位置を System の底辺の真下
% に設定し、それらのsubsystemブロックの左側に整列させます。
%
% この関数は、主として、すべてのプラットフォームにおいて、ブロックライブラリを
% 正確に整列させるのを補助するために用いられます。この方法で利用するためには、
% ブロックライブラリの PostLoadFcn を、ブロックライブラリ名を使ってこの関数
% を呼び出すように設定します。
%
%  set_param(blockLib, 'PostLoadFcn', 'setsysloc blockLib')
%
% 参考 : SET_PARAM.


% Copyright 1990-2002 The MathWorks, Inc.
