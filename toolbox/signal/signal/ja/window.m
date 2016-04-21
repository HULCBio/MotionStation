% WINDOW Window 関数 ゲートウェイ
%
% WINDOW(@WNAME,N) は、列ベクトルで、関数ハンドル@WNAMEにより
% 指定されるタイプのN-点 ウィンドウを返します。
% @WNAME は、任意の正しいウィンドウ関数名となります。
% たとえば、つぎのようなものです。:
%
%   @bartlett       - Bartlett ウィンドウ
%   @barthannwin    - Modified Bartlett-Hanning ウィンドウ 
%   @blackman       - Blackman ウィンドウ
%   @blackmanharris - 最小4項Blackman-Harris ウィンドウ
%   @bohmanwin      - Bohman ウィンドウ
%   @chebwin        - Chebyshev ウィンドウ
%   @flattopwin     - Flat Top ウィンドウ
%   @gausswin       - Gaussian ウィンドウ
%   @hamming        - Hamming ウィンドウ
%   @hann           - Hann ウィンドウ
%   @kaiser         - Kaiser ウィンドウ
%   @nuttallwin     - Nuttall の定義による最小4項Blackman-Harris ウィンドウ
%   @parzenwin      - Parzen (de la Valle-Possin)ウィンドウ
%   @rectwin        - 長方形ウィンドウ
%   @tukeywin       - Tukey ウィンドウ
%   @triang         - 三角ウィンドウ
%
% WINDOW(@WNAME,N,OPT) は、OPTに指定されるオプションの入力引数をもつ
% ウィンドウを設計します。オプションの入力引数について知るためには、
% たとえば、 KAISER あるいは CHEBWIN のような、個々のウィンドウの
% ヘルプを参照してください。
%
% WINDOW は、Window Design & Analysis ツール(WinTool) を起動します。
%
% 例題: 
%       N  = 65;
%       w  = window(@blackmanharris,N);
%       w1 = window(@hamming,N);
%       w2 = window(@gausswin,N,2.5);
%       plot(1:N,[w,w1,w2]); axis([1 N 0 1]);
%       legend('Blackman-Harris','Hamming','Gaussian');
% 
% 参考: BARTLETT, BARTHANNWIN, BLACKMAN, BLACKMANHARRIS, 
%       BOHMANWIN, CHEBWIN, GAUSSWIN, HAMMING, HANN, KAISER,
%       NUTTALLWIN, PARZENWIN, RECTWIN, TRIANG, TUKEYWIN.


%    Author(s): P. Costa 
%    Copyright 1988-2002 The MathWorks, Inc.
