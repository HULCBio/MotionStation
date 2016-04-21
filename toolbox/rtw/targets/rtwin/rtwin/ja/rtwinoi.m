% RTWINOI は、Real-Time Windows Target への他の入力です。
%
% この関数は、Real Time Windows Target で使われます。これは、"Other In-
% put"用のダミーの S-function です。従って、Simulink シミュレーションの
% 間、適切な数の出力を使って、ゼロを出力するだけです。その後で、モデルが、
% RTW を通してコンパイルされたとき、このブロックは、固有のハードウエアア
% ダプタ(デバイスドライバ)で置き換えられ、ハードウエアに特別な I/O デバ
% イスから新しいデータを取り込むようになります。
%
% 直接、コールすることはありません。

% $Revision: 1.3 $ $Date: 2002/04/14 18:52:44 $
%   Copyright 1994-2002 The MathWorks, Inc.
