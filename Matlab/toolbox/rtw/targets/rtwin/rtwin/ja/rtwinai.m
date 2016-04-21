% RTWINAI は、Real-Time Windows Target アナログ入力です。
%
% 関数は、Real Time Windows Target で使われます。これは、"Analog Input" 
% ブロック用のダミーのS-function です。従って、Simulink シミュレーション
% の間、適切な数の出力を使って、ゼロを出力するだけです。その後、モデルが、
% RTW を通してコンパイルされたとき、このブロックは、固有のハードウエアア
% ダプタ(デバイスドライバ)で置き換えられ、ハードウエアに特別な I/O デバ
% イスから新しいデータを取り込むようになります。
%
% 直接、コールすることはありません。

% $Revision: 1.3 $ $Date: 2002/04/14 18:52:32 $
%   Copyright 1994-2002 The MathWorks, Inc.
