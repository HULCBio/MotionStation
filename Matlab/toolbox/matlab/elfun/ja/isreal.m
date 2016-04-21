% ISREAL   実数配列の検出
% 
% ISREAL(X)は、Xが虚部をもたない場合は1を出力し、そうでなければ0を出力
% します。
%
% ~ISREAL(X) は、すべての要素がゼロの場合でさえも、虚数部をもつ配列を検出
% します。
% ~ANY(IMAG(X(:))) は、厳密な意味での実数配列を検出します。ここで、X は、
% すべてゼロを割り当てているか、または、割り当てているものがないかのどち
% らかです。
%
% 例題：
%      x = magic(3);
%      y = complex(x);
% この場合、isreal(x) は真で、isreal(y) は偽を出力します。COMPLEXは、
% 虚数部すべてがゼロとなる y を出力するからです。
%
% 参考：REAL, IMAG, COMPLEX, I, J.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:50:27 $
%   Built-in function.

