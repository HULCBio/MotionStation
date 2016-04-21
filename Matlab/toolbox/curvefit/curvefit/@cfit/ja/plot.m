% PLOT  CFIT オブジェクトをプロット
% PLOT(F) は、カレント axes の x のレンジ全体に F をプロットします。
% その他の場合、近似で使われたデータのレンジ全体をプロットします。
%
% PLOT(F,XDATA,YDATA) は、XDATA に対して、YDATA を、XDATA のレンジ全体に 
% F をプロットします。
%
% PLOT(F,XDATA,YDATA,EXCLUDEDATA) は、種々のカラーで削除するデータをプロ
% ットします。EXCLUDEDATA は、論理配列で、1は異常値を表わします。
%
% PLOT(F,'S1',XDATA,YDATA,'S2',EXCLUDEDATA,'S3') は、文字列 'S1', 'S2', 
% 'S3' を使って、指定したラインのラインタイプ、プロットシンボル、カラー
% をコントロールします。これらの文字列は、省略しても構いません。
%
%   PLOT(F,...,'PTYPE')
%   PLOT(F,...,'PTYPE',CONFLEV)
%   PLOT(F,...,'PTYPE1',...,'PTYPEN',CONFLEV) 
% は、プロットタイプと信頼レベルをコントロールします。CONFLEV は、1より
% 小さい正の値で、デフォルトは 0.95 (95% 信頼区間)です。'PTYPE' は、つぎ
% の文字列のいずれか、または、つぎの文字列のセル配列を設定することができ
% ます。
% 
%  'fit'         データと近似カーブをプロット (デフォルト)
%  'predfunc'    'fit' と同じですが、関数に対する予測範囲をもっています。
%  'predobs'     'fit' と同じですが、新しい観測に対する予測範囲をもって
%                います。
%  'residuals'   近似をゼロラインで表わし、残差をプロットします。
%  'stresiduals' 近似をゼロラインで表わし、標準化された残差をプロットし
%                ます。
%  'deriv1'      1階微係数をプロット
%  'deriv2'      2階微係数をプロット
%  'integral'    積分をプロット
%
% H = PLOT(F,...) は、プロットされたオブジェクトのハンドルを要素とする
% ベクトルを出力します。
%
% 参考 PLOT, EXCLUDEDATA

% $Revision: 1.2.4.1 $


%   Copyright 2001-2004 The MathWorks, Inc.
