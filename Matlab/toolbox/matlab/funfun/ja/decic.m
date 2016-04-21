%DECIC  ODE15I に対する矛盾のない初期条件を計算
% [Y0MOD,YP0MOD] = DECIC(ODEFUN,T0,Y0,FIXED_Y0,YP0,FIXED_YP0) は、
% F(T0,Y0MOD,YP0MOD) = 0 を満たす出力値を見つけるための繰り返しに
% 初期の推定値として、入力 Y0,YP0 を使用します。DECIC は、推定の要素を
% できる限り変更しないようにします。Y0(i) の推定に変更が許されていない
% 場合、FIXED_Y0(i) = 1 と設定することにより、ある要素が固定されるよう
% に指定でき、そうでない場合、0 と指定します。FIXED_Y0 を空の配列とする
% と、すべての要素で変更が可能であると解釈されます。FIXED_YP0 は、同様
% に扱われます。
%
% length(Y0) よりも多くの要素を固定することはできません。問題に依存して、
% これだけ多くを固定できない可能性があります。Y0 または YP0 の特定の
% 要素を固定できない可能性もあります。必要以上の要素を固定しないことを
% お勧めします。
% 
% [Y0MOD,YP0MOD] = DECIC(ODEFUN,T0,Y0,FIXED_Y0,YP0,FIXED_YP0,OPTIONS)
% は、ODESET 関数で作成された構造体、OPTIONS の値により置き換えられた
% 積分特性のデフォルト値を使用して上記のように計算します。
%
% [Y0MOD,YP0MOD] = DECIC(ODEFUN,T0,Y0,FIXED_Y0,YP0,FIXED_YP0,OPTIONS,P1,P2...)
% は、付加パラメータ P1,P2,... を、ODEFUN(T,Y,YP,P1,P2...) として、
% ODE 関数、および、OPTIONS に指定されたすべての関数に渡します。
% オプションが設定されていない場合、プレースホルダとして OPTIONS = [] を
% 使用してください。
%
% [Y0MOD,YP0MOD,RESNRM] = DECIC(ODEFUN,T0,Y0,FIXED_Y0,YP0,FIXED_YP0...)
% は、ODEFUN(T0,Y0MOD,YP0MOD) のノルムを RESNRM として出力します。
% ノルムが大きすぎるようにみえる場合、より小さい RelTol (デフォルトは、
% 1e-3) を指定するために OPTIONS を使用してください。
%
%
% 参考 ODE15I, ODESET, IHB1DAE, IBURGERSODE.

% Jacek Kierzenka and Lawrence F. Shampine
% Copyright 1984-2003 The MathWorks, Inc.
