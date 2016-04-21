% SET   serial port オブジェクトプロパティの設定または表示
%
% SET(OBJ,'PropertyName',PropertyValue) は、serial port オブジェクト 
% OBJ に、指定したプロパティ PropertyName に値 PropertyValue を設定
% します。
%
% OBJ は、serial port オブジェクトのベクトルで、この場合、SET は、
% すべての serial port オブジェクトに指定されたプロパティ値を設定します。
%
% SET(OBJ,S) は、構造体の中に含まれる値を使って、各フィールド名に名付け
% られたプロパティを設定します。ここで、S は、オブジェクトプロパティ名
% である構造体のフィールド名です。
%
% SET(OBJ,PN,PV) は、文字列のセル配列 PN に指定したプロパティを、OBJ の
% 中に指定したすべてのオブジェクトに対して、セル配列 PV の中の対応する値
% に設定します。セル配列 PN はベクトルで、セル配列 PV は、M 行 N 列です。
% ここで、 M は、length(OBJ)で、N は、length(PN) です。それで、各オブジェ
% クトは、PN の中に含まれるプロパティ名のリストに対して、種々の値で更新
% されます。
%
% SET(OBJ,'PropertyName1',PropertyValue1,'PropertyName2',PropertyValue2,...)
% は、一つのステートメントで、複数のプロパティ値を設定します。ここでは、
% SET へのコールと同じように、プロパティ-値の文字列の組、構造体、プロパ
% ティ-値のセル配列の組を使うことが許可されていることに注意してください。
%
% SET(OBJ, 'PropertyName') 
% PROP = SET(OBJ,'PropertyName') は、serial port オブジェクト OBJ の指定
% したプロパティ、PropertyName に設定できる可能な値を表示するか、出力し
% ます。出力される配列 PROP は、プロパティは、可能な文字列値の有限な組を
% もっていない場合、可能な値の文字列、または、空セル配列のいずれかのセル
% 配列になります。
%   
% SET(OBJ) 
% PROP = SET(OBJ) は、serial port オブジェクト OBJ に設定したすべての
% プロパティ名と値を表示、または、出力します。出力される値、PROP は、
% OBJ のプロパティ名、または、プロパティ値が、取り得る可能な値のセル配列、
% または、空のセル配列のいずれかをフィールド名とする構造体です。
%
% 例題:
%       s = serial('COM1');
%       set(s, 'BaudRate', 9600, 'Parity', 'even');
%       set(s, {'StopBits', 'RecordName'}, {2, 'sydney.txt'});
%       set(s, 'Name', 'MySerialObject');
%       set(s, 'Parity')
%
% 参考 : SERIAL/GET.
%


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
