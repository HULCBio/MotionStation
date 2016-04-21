% TRIM   条件を与えられたシステムに対する定常状態パラメータを算出
%
%
% TRIM は、ある入力、出力、状態の条件を満たす定常状態パラメータを求めます。
%
% [X,U,Y,DX] = TRIM('SYS') は、S-Function 'SYS' の状態微係数 DX をゼロに設定
% する X,U,Y の値を求めます。TRIM は、制限付き最適化手法を用います。
%
% [X,U,Y,DX] = TRIM('SYS',X0,U0) は、X と U に対する初期推定をそれぞれX0 と
% U0 に設定します。
%
% [X,U,Y,DX] = TRIM('SYS',X0,U0,Y0,IX,IU,IY) は、X, U, Y を X0(IX),U0(IU),
% Y0(IY) に固定します。変数 IX, IU, IY は、インデックスのベクトルです。
% この問題の解が求められない場合は、TRIM は、意図する値からの最大微係数を最小
% にする値を求めます。IX が空でなく、すべての状態を含まない場合は、IX でインデッ
% クス付けされない状態を変更できます。同様に、IU が空でなく、すべての入力を含
% まない場合は、IU から取り除かれた入力を変更できます。
%
% [X,U,Y,DX] = TRIM('SYS',X0,U0,Y0,IX,IU,IY,DX0,IDX) は、IDX によってインデッ
% クス付けられた微係数を DX(IDX) に固定します。インデックス付けられていない
% 微係数は、変更できます。
%
% [X,U,Y,DX] = TRIM('SYS',X0,U0,Y0,IX,IU,IY,DX,IDX,OPTIONS) は、最適化パラメー
% タを設定できます。詳細は、Optimization ToolboxのCONSTR を参照してください。
% Optimization Toolboxでおもちでない場合は、オンラインドキュメントを参照して
% ください。
%
% [X,U,Y,DX] = TRIM('SYS',X0,U0,Y0,IX,IU,IY,DX0,IDX,OPTIONS,T) は、時間に依
% 存するシステムに対して、時間を T に設定します。
%
% 詳細は、TYPE TRIM と入力してください。
% 参考  LINMOD.
%
%


% Copyright 1990-2002 The MathWorks, Inc.
