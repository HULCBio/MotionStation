% RPTGENUTIL   report generatorに対するユーティリティ機能を提供
% RPTGENUTILは、report generatorの非オブジェクト指向部分で用いられるいく
% つかの小さいユーティリティのアクションを含んでいます。
% RPTGENUTILは、RPTGENUTIL(ACTION,OPTIONS)の書式で呼び出されます。
%
% アクション:
% 
%   S=RPTGENUTIL('EmptyComponentStructure',COMPONENTNAME)
%
%   N=RPTGENUTIL('SimulinkSystemReportName',SYSNAME)
% 
% SYSNAMEは、Simulinkシステム名、または、ハンドルです。Nは、システムに対
% 応するReportNameの名前です。
%
%   [NUM,ERRORMSG]=RPTGENUTIL('str2numNxN',STRING,OLDNUMBER);
% 
% "2.5x3"のような文字列を[2.5 3]のような数値に変換します。
%
%   [NUM,ERRORMSG] = RPTGENUTIL('str2numNxN',HANDLE,OLDNUMBER);
% 
% 上記の関数のように動作しますが、HANDLEから文字列の値を取得し、HANDLEの
% 文字列を終了時に設定します。
%
%   STR=RPTGENUTIL('num2strNxN',NUM,HANDLE);
% 
% [2.5 3]のようなベクトルを'2.5x3'に変換します。HANDLEが与えられる場合は
% (オプション)、文字列はHANDLEのカレントの'string'プロパティに設定されま
% す。
%
%   SIZE = RPTGENUTIL('SizeUnitTransform',oldSize,....
%             oldUnits,newUnits,strHandle)
% 
% M行N列の配列を以前の単位から新たな単位に変更します。オプションのuico-
% ntrolのハンドルは、新たなM行N列の値の文字列表現を表示します。
%
%   [VNAME,ERRORMSG] = RPTGENUTIL('VariableNameCheck',NEWNAME,.....
%               OLDNAME,ISPUNCTOK)  
%  
% 変数(NEWNAME)に対する名前、および変数に(有効と仮定される)以前の名前を
% 与えるときには、新たな変数が有効な名前であることを確認します。有効でな
% い場合は、強制的に有効にします。失敗した場合は、以前の名前を出力します。
% ハンドル(オプション)が渡される場合は、オブジェクトの'String'プロパティ
% を新たな変数名に設定します。
%
% NEWNAMEは、edit uicontrolのハンドルでも構いません。この場合、NEWNAMEは
% 'String'プロパティから得られます。Stringプロパティは、その後修正された
% 名前によって設定されます。
% 
% ISPUNCTOKは、変数名で句読点キャラクタを用いることができるかどうかを通
% 知するboolean値です。
% 





%   Copyright (c) 1997-2001 by The MathWorks, Inc. All Rights Reserved.
