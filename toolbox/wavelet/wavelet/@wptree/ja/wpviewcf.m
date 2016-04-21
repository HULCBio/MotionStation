%WPVIEWCF   ウェーブレットパケットの色付けされた係数をプロット
%   WPVIEWCF(T,CMODE) は、ツリー T の末端ノードに対して色付けされた係数
%   をプロットします。
%   T は、WPTREE オブジェクトです。
%   CMODE は、以下のカラーモードを示す整数です。
%       1: 'FRQ : Global + abs'
%       2: 'FRQ : By Level + abs'
%       3: 'FRQ : Global'
%       4: 'FRQ : By Level'
%       5: 'NAT : Global + abs'
%       6: 'NAT : By Level + abs'
%       7: 'NAT : Global'
%       8: 'NAT : By Level'
%
%   wpviewcf(T,CMODE,NB) は、NB 個のカラーを使います。
%
%   例題:
%     x = sin(8*pi*[0:0.005:1]);
%     t = wpdec(x,4,'db1');
%     plot(t);
%     wpviewcf(t,1);
%
%   参考: WPDEC

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Sep-96.


%   Copyright 1995-2002 The MathWorks, Inc.
