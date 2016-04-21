% LINSUB   SIMULINKのモデルの線形部分
%
% SYS = LINSUB('MODEL',HIN,HOUT) は、SIMULINK モデル 'MODEL' の中のいく
% つかのサブシステムの線形化された状態空間モデルを得ます。サブシステムの
% 入力は、ハンドル HIN をもつInputPoint ブロックで定義され、出力は、ハン
% ドル HOUT をもつ OutputPoint ブロックで定義されます。状態変数と入力は
% ゼロに設定されます。
%
% SYS = LINSUB('MODEL',HIN,HOUT,T,X,U) は、さらに、全体のモデルに対して
% 線形化を実行する点 (T, X, U) を設定します。ここで、 T は時間、X は状態
% 変数名と値からなる構造体、Uは外部入力のベクトルです。X = [] または 
% U = [] は、矛盾のない大きさのゼロ行列を設定します。
%
% 状態変数値を設定する場合、構造体はつぎの2つのフィールドを必要とします。
%   
%   Names  = 状態名のセル配列
%   Values = 状態名の順番に従った状態の値を要素とするベクトル
%
% SYS = LINSUB('MODEL',HIN,HOUT,...,OPTIONS) は、設定する必要のある線形化
% オプションです。OPTIONS は、つぎのフィールド名をもつ構造体です。
% 
%   SampleTime  - 離散システムに対して使用するサンプリング時間(デフォルト
%                 は、個々のブロックのサンプリング時間の最小公倍数)
%
% 参考 : LINMOD, DLINMOD


%   Conversion to LINMOD: G. Wolodkin 12/15/1999
%   Authors: K. Gondoly, A. Grace, R. Spada, and P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $
