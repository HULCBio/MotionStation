% SUBSASGN は、xPC スコープオブジェクトに割り当てます。
% 
% 割り当ては、'.'インタックスに対してのみ適用されます。すなわち、ステート
% メント SET(XPCSCOPEOBJ, 'TriggerMode', 'Signal) は、XPCSCOPEOBJ. Trigg-
% erMode = 'Signal' で置き換えられます。割り当ては、スコープオブジェクトの
% ベクトルに対しても可能で、たとえば、XPCSCOPEOBJ([1, 3]).Grid = 'on' です。
% 
% これは、直接、コールすることを目的としていない、プライベート関数です 。
% 
% 参考： SUBSREF.

%   Copyright 1994-2002 The MathWorks, Inc.
