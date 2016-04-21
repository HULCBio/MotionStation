% RTWINAO は、Real-Time Windows Target アナログ出力です。
%
% 関数は、Real Time Windows Target で使われます。これは、"Analog Output"
% ブロック用のダミーのS-function です。従って、Simulink シミュレーショ
% ンの間、適切な数の出力を使って、ゼロを出力するだけです。その後で、モデ
% ルが、RTW を通してコンパイルされたとき、このブロックは、固有のハードウ
% エアアダプタ(デバイスドライバ)で置き換えられ、ハードウエアに特別な I/O
% デバイスから新しいデータを取り込むようになります。
%
% 直接、コールすることはありません。

% $Revision: 1.3 $ $Date: 2002/04/14 18:52:35 $
%   Copyright 1994-2002 The MathWorks, Inc.
