% CLASS   オブジェクトの作成、または、オブジェクトのクラスの出力
%
% VAL = CLASS(OBJ) は、オブジェクトOBJのクラスを出力します。
%
% コンストラクトメソッドと共に CLASS(S,'class_name') は、構造体 S から
% クラス 'class_name' のオブジェクトを作成します。このシンタックスは、
% ディレクトリ@<class_name> の関数名<class_name>の中でのみ正しいものです
% (ここで、<class_name> は、CLASS へ渡される文字列と同じです)。
% 
% CLASS(S,'class_name',PARENT1,PARENT2,...) は、親オブジェクト PARENT1, 
% PARENT2, ...　のメソッドとフィールドを継承します。
% 
% 参考 : ISA, SUPERIORTO, INFERIORTO, STRUCT.


%    MP 07-13-99
%    Copyright 1999-2002 The MathWorks, Inc. 
