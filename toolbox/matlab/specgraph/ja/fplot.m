% FPLOT   関数のプロット
% 
% FPLOT(FUN,LIMS) は、LIMS = [XMIN XMAX] で指定されたx軸の範囲に、文字列 
% FUN で指定した関数をプロットします。LIMS = [XMIN XMAX YMIN YMAX] を
% 使うと、y軸の範囲を設定できます。関数 FUN(x)は、ベクトル x の各要素に
% 対する行ベクトルを出力しなければなりません。たとえば、FUN が
% [f1(x),f2(x),f3(x)] を出力すると、入力 [x1;x2] に対して、関数はつぎの
% 行列を出力します。
%
%     f1(x1) f2(x1) f3(x1)
%     f1(x2) f2(x2) f3(x2)
% 
% FPLOT(FUN,LIMS,TOL) は、TOL < 1 のとき、相対許容誤差を指定します。
% デフォルトの TOL は、2e-3、すなわち、0.2%の精度です。FPLOT(FUN,LIMS,N)
% は、N > =  1 のとき、N+1 点の最小値をもつ関数をプロットします。デフォルト
% の N は1です。最大ステップサイズは、(1/N)*(XMAX-XMIN) に制限されます。
% FPLOT(FUN,LIMS,'LineSpec') は、指定したlineの仕様を使ってプロットします。
% FPLOT(FUN,LIMS,...) は、オプションの引数 TOL、N、'LineSpec' を任意の順序
% で組み合わせて使用します。
% 
% [X,Y] = FPLOT(FUN,LIMS,...) は、Y = FUN(X) であるような X と Y を出力
% します。スクリーン上には、何もプロットされません。
%
% [...] = FPLOT(FUN,LIMITS,TOL,N,'LineSpec',P1,P2,...) は、パラメータ 
% P1,P2,...等を関数 FUN に渡します。
% 
%     Y = FUN(X,P1,P2,...)
% 
% TOL,N,'LineSpec' に対するデフォルト値を使うためには、空行列 [] を設定
% してください。
%
% 例題:
% FUN は、@ またはインラインオブジェクト、方程式表現を使って指定する
% ことができます。
%       subplot(2,2,1), fplot(@humps,[0 1])
%
%       f = inline('abs(exp(-j*x*(0:9))*ones(10,1))');
%       subplot(2,2,2), fplot(f,[0 2*pi])
%
%       subplot(2,2,3), fplot('[tan(x),sin(x),cos(x)]',2*pi*[-1 1 -1 1])
%       subplot(2,2,4), fplot('sin(1 ./ x)', [0.01 0.1],1e-3)


%   Mark W. Reichelt 6-2-93
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:05:09 $
