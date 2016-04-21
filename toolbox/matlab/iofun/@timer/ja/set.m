% SET   timer オブジェクトプロパティの設定または表示
% 
% SET(OBJ) は、timer オブジェクト OBJ の設定可能なすべてのプロパティに
% 対して可能な値とプロパティ名を表示します。OBJ は、単一の timer オブ
% ジェクトでなければなりません。
%
% PROP_STRUCT = SET(OBJ) は、timer オブジェクト OBJ の設定可能なすべての
% プロパティに対して設定可能な値とプロパティ名を出力します。OBJ は、
% 単一の timer オブジェクトでなければなりません。出力値 PROP_STRUCT は、
% フィールド名が OBJ のプロパティ名である構造体です。また、プロパティが
% 有限な文字列の値の設定がされていない場合、値は可能なプロパティ値の
% セル配列か、または空のセル配列である構造体になります。
%
% SET(OBJ,'PropertyName') は、timer オブジェクト OBJ に指定されたプロ
% パティ PropertyName に対して設定可能な値を表示します。OBJ は、単一の 
% timer オブジェクトでなければなりません。
%
% PROP_CELL = SET(OBJ,'PropertyName') は、timer オブジェクト OBJ に
% 指定されたプロパティ PropertyName に対する設定可能な値を出力します。
% OBJ は、単一の timer オブジェクトでなければなりません。出力値 PROP_CELL
% は、プロパティが有限な文字列の値の設定がされていない場合、設定可能な
% 文字列のセル配列か、空のセル配列です。
%
% SET(OBJ,'PropertyName',PropertyValue,...) は、timer オブジェクト OBJ
% に対するプロパティ PropertyName に、指定された値 PropertyValue を
% 設定します。ユーザは、単一のステートメント内に 名前/プロパティ値の
% 組み合わせで複数のプロパティを指定することができます。OBJ は、単一の
% timer オブジェクトか、timer オブジェクトのベクトルです。ベクトルの
% 場合、SET は、すべての指定された timer オブジェクトに対してプロパティ
% 値を設定します。
%
% SET(OBJ,S) は、構造体の中に含まれる値を使って、各フィールド名に名付け
% られたプロパティを設定します。ここで、S は、オブジェクトプロパティ名
% である構造体のフィールド名です。
%
% SET(OBJ,PN,PV) は、文字列のセル配列 PN に指定したプロパティを、timer 
% オブジェクト OBJ の中に指定したすべてのオブジェクトに対して、セル配列 
% PV の中の対応する値に設定します。PN はベクトルでなければなりません。
% OBJ が timer オブジェクトのセル配列である場合、PV は、M 行 N 列のセル
% 配列です。ここで、 M は、length(OBJ)で、N は、length(PN) です。この
% 場合、各 timer オブジェクトは、PN の中に含まれるプロパティ名のリスト
% に対して、種々の値で更新されます。
%
% パラメータ-値 の文字列の組み合わせの構造体と、パラメータ-値のセル配列
% の組み合わせは、SET と同じ呼び出しを使用します。
%
% 例題:
%     t = timer;
%     set(t) % すべての設定可能なプロパティと値を表示
%     set(t, 'ExecutionMode') % プロパティのすべての設定可能な値を表示
%     set(t, 'TimerFcn', 'callbk', 'ExecutionMode', 'FixedRate')
%     set(t, {'StartDelay', 'Period'}, {30, 30})
%     set(t, 'Name', 'MyTimerObject')
%
% 参考 : TIMER, TIMER/GET.


%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:57:44 $
