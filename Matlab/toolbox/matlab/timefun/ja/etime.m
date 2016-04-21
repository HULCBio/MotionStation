% ETIME   経過時間
% 
% ETIME(T1,T0) は、ベクトル T1 と T0 の間の経過時間を秒単位で出力します。
% 2つのベクトルは、CLOCK から出力される書式で、6要素でなければなりません。
%
%    T = [Year Month Day Hour Minute Second]
%
% 大きさの次元が大きく異なっていても正確に計算できます。T1 と T0 の最初の
% 5つの要素に違いがある場合は数千秒になり、最初の5つの要素が等しい場合は
% わずかな違いがでます。
%
%     t0 = clock;
%     operation
%     etime(clock,t0)
%
% 参考：TIC, TOC, CLOCK, CPUTIME, DATENUM.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 02:07:30 $
