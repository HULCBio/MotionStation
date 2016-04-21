% BOUNDEDLINE 信頼範囲を含んだ関数ラインを作成
% H = BOUNDEDLINE(FUN) は、関数 FUN をベースにしたラインを作成します。
% FUN は、ベクトル X を入力して、X で設定した点で計算した FUN の値を要
% 素とするベクトルを出力します。
%
% H = BOUNDEDLINE(FUN,SHOWBOUNDS,CONFLEVEL,DFE) は、信頼範囲をコントロ
% ールします。SHOWBOUNDS を 'on'(デフォルト)と設定すると、範囲が表示さ
% れ、'off'の場合は非表示になります。CONFLEVEL は、信頼レベルを設定する
% もので、デフォルトは、0.95 です。DFE は、誤差に対する自由度で、デフォ
% ルトは、Inf です。
%
% H = BOUNDEDLINE(FUN,...,'-userargs',{P1,P2,...}) を使って、ユーザ設定
% の引数を、FUN に渡すことができます。引数の設定は、カンマで分離した型で
% 設定します。たとえば、つぎのようにします。
% 
%    feval(FUN,X,P1,P2,...).
%
% H = BOUNDEDLINE(FUN,...,'String','STR') は、String プロパティの初期値を
% 'STR' で設定します。
%
% H = BOUNDEDLINE(FUN,...,PROP1,VALUE1,PROP2,VALUE2,...) は、与えられた値
% に設定されたプロパティをもつラインを作成します。たとえば、'color', 'b' 
% のようなペアで設定します。

% $Revision: 1.2.4.1 $
%   Copyright 2001-2004 The MathWorks, Inc.
