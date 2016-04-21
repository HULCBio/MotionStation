%WPTHCOEF   ウェーブレットパケット係数のスレッシュホールド操作
%   NEWT = WPTHCOEF(T,KEEPAPP,SORH,THR) は、係数のスレッシュホールド操作%   によるウェーブレットパケットツリー T から得られる、新しいウェーブ
%   レットパケットツリー NEWT を出力します。
%
%   KEEPAPP = 1 の場合、approximation 係数にはスレッシュホールドは適用さ%   れません。その他の場合は、適用される可能性があります。
%   SORH = 's' の場合、ソフトスレッシュホールドが適用されます。
%   SORH = 'h' の場合、ハードスレッシュホールドが適用されます (WTHRESH 
%   を参照)。
%   
%   THR は、スレッシュホールド値です。
%
%   参考: WPDEC, WPDEC2, WPDENCMP, WTHRESH

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.


%   Copyright 1995-2002 The MathWorks, Inc.
