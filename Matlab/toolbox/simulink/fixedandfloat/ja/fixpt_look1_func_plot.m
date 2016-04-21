% fixpt_look1_func_plot   - 理想的な関数とそのルックアップ近似のプロット
%
%
% ERRWORST = FIXPT_LOOK1_FUNC_PLOT( XDATA, YDATA, FUNCSTR, XMIN, XMAX,
% XDT, XSCALE, YDT, YSCALE, RNDMETH)?I?AXMIN?(c)?cXMAX?I"I?I?A-?'z"I?E?O?
% "FUNCSTR?d?v???b?g?μ?U?・?Bまた、データ点XDATAとYDATAによって決定されるルッ
% クアップテーブル近似もプロットします。理想とルックアップテーブル近似との間の
% 誤差もプロットされます。ルックアップテーブル計算は、入力データタイプXDT?A"
% u-I?X?P?[???"?OXSCALE?A?o-I?f?[?^?^?C?vYDT?A?o-I?X?P?[???"?OYSCALE?A?
% o-]?・?e?U?s???[?hRNDMETH?d-p?￠?A?A?"?3?e?U?・?B
% これらの引数は、Fixed-Point Blockset?A-p?￠?e-p-@?E?]?￠?U?・?B
% 最悪ケースの誤差ERRWORST?I?A-?'z"I?E?O?"FUNCSTR?A?"?IXMIN?(c)?cXMAX?U?A?
% I?s?-?A?I?O?I?A'a?a'I?e?・?E'e?`?3?e?U?・?B
%
% Inputs XDATA    ルックアップテーブル近似により用いるブレークポイント　
% YDATA    ブレークポイントに対応する出力データ点　　FUNCSTR  入力ベクトルxに対
% する理想的な関数の出力に対応する出力データ点たとえば、'sin(2*pi*x)' ?U?1/
% 2?I?@'sqrt(x)' XMIN      ?A?￢"u-I'lXMAX      最大入力値
% XDT       Fixed-Point Blocksetの用法を用いて指定した入力データタイプ
%  たとえば、sfix(16), ufix(8), float('single') ?@
% XSCALE   Fixed-Point Blockset?I-p-@?d-p?￠?A?w'e?3?e?1/2"u-I?X?P?[???"?
% Oたとえば、2^-6 は小数点の6ビット右を意味します。YDT      出力データタイプ
% YSCALE   出力スケーリング
% RNDMETH  丸め方法
% 'floor' (デフォルト), 'ceil', 'near', 'zero'
%
% Outputs  ERRWORST 理想的な関数とルックアップ近似との間の最悪ケース誤差
%
% 例題
% xdata = linspace(0,0.25,5).';
% ydata = sin(2*pi*xdata);
% FIXPT_LOOK1_FUNC_PLOT(xdata, ydata, 'sin(2*pi*x)', 0, 0.25, ...
% ufix(8), 2^-8, sfix(16), 2^-14, 'Floor')
%
% 参考 : SFIX, UFIX,


% Copyright 1994-2002 The MathWorks, Inc.
