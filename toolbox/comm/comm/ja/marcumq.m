% MARCUMQ   一般化 Marcum Q 関数
%
% MARCUMQ(A,B,M) は、つぎのように定義される一般化 Marcum Q 関数です。
%
%      Q_m(a,b) = 1/a^(m-1) * integral from b to inf of
%                 [x^m * exp(-(x^2+a^2)/2) * I_(m-1)(ax)] dx
%
% a,b と m は、実数で、非負です。m は整数です。
%
% MARCUMQ(A,B) は、もともと、Marcum により一覧にされたもので、M = 1 に
% 対して特別なものです。そして、しばしば、サブスクリプトなしに Q(a,b) と
% 記述されることもあります。


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:34:59 $
