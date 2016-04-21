% RTWINDO は、Real-Time Windows Target デジタル出力です。
%
% 関数は、Real Time Windows Target で使われます。これは、"Digital Output" 
% ブロック用のダミーのS-function です。従って、Simulink シミュレーション
% の間、適切な数の出力を使って、ゼロを出力するだけです。その後で、モデル
% が、RTW を通してコンパイルされたとき、このブロックは、固有のハードウエ
% アアダプタ(デバイスドライバ)で置き換えられ、ハードウエアに特別な I/O 
% デバイスから新しいデータを取り込むようになります。
%
% 直接、コールすることはありません。

% $Revision: 1.3 $ $Date: 2002/04/14 18:52:41 $
%   Copyright 1994-2002 The MathWorks, Inc.
