% SHIFTDIM   次元のシフト
%
% B = SHIFTDIM(X,N) は、N によって X の次元をシフトします。N が正の
% とき、SHIFTDIM は、左に次元をシフトし、最後の次元をNに導くように
% まわります。N が負の場合、SHIFTDIM は、右に次元をシフトし、単一の
% 次元を詰めます。
%
% [B,NSHIFTS] = SHIFTDIM(X) は、X と同じ要素数をもち、その前に位置する
% 次元1の要素を削除した配列 B を出力します。NSHIFTS は、削除された次元
% の数です。X がスカラの場合、SHIFTDIM は何も行いません。
%
% SHIFTDIM は、SUM や DIFF のように、最初に1でない次元に対して使用する
% 関数の作成に役立ちます。
%
% 例題:
%       a = rand(1,1,3,1,2);
%       [b,n]  = shiftdim(a); % b は 3×1×2 で、n は 2 です。
%       c = shiftdim(b,-n);   % c == a.
%       d = shiftdim(a,3);    % d は 1×2×1×1×3 です。
%
% 参考:  CIRCSHIFT, RESHAPE, SQUEEZE.



%   Copyright 1984-2004 The MathWorks, Inc. 
