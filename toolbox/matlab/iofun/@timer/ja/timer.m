% TIMER   timer オブジェクトの作成
%
% T = TIMER は、デフォルトの属性を使って timer オブジェクトを作成します。
%
% T = TIMER('PropertyName1',PropertyValue1, 'PropertyName2', PropertyValue2,...)
% は、与えられたプロパティの名前/値の組み合わせをオブジェクトに設定した 
% timer オブジェクトを作成します。
%
% プロパティ名と値の組は、関数 SET でサポートされている任意のフォーマット
% で記述できることに注意してください。たとえば、パラメータ-値の文字列の
% 組、構造体、セル配列等です。
% 
% 例題:
%       % timer コールバックを mycallback として10秒間の 
%       % timer オブジェクトを作成します。
%         t = timer('TimerFcn',@mycallback, 'Period', 10.0);
%
%
% 参考 : TIMER/SET, TIMER/TIMERFIND, TIMER/START, TIMER/STARTAT.


%    RDD 10/23/01
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:57:49 $
