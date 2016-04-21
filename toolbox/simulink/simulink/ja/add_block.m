% ADD_BLOCK   Simulinkシステムにブロックを付加
%
% ADD_BLOCK('SRC','DEST') は、絶対パス名'SRC'のブロックを絶対パス名'DEST'の
% 新しいブロックにコピーします。新しいブロックのブロックパラメータは、オリジナ
% ルのブロックパラメータと一致します。名前'built-in'は、すべてのSimulink組み込
% みブロックに対して、ソースシステム名として使用することができます。
%
% ADD_BLOCK('SRC','DEST','PARAMETER1',VALUE1,...) は、名前を指定されたパラメー
% タが指定の値をもつ、上記のようなコピーを作成します。追加引数はすべて、パラメー
% タと値の組み合わせで指定しなければなりません。
%
% ADD_BLOCK('SRC','DEST','MAKENAMEUNIQUE','ON','PARAMETER_NAME1',VALUE1,.
% ..)は、上記のようにコピーを作成し、絶対パス名'DEST'のブロックが既に存在する
%
% ADD_BLOCK('SRC','DEST','COPYOPTION','DUPLICATE','PARAMETER_NAME1',
% VALUE1,...)は、INPORTブロックに対して動作し、'SRC'ブロックと同じ端子番号を
%
% 例題:
%
% add_block('simulink/Sinks/Scope','engine/timing/Scope1')
%
% は、ScopeブロックをSimulinkシステムのSinksサブシステムから、engineシス
% テムの timing サブシステム内のScope1という名前のブロックにコピーします。
%
% add_block('built-in/SubSystem','F14/controller')
%
% は、F14システム内にcontrollerという名前の新しいサブシステムを作成しま
%
% す。 add_block('built-in/Gain','mymodel/volume','Gain','4')
%
% は、組み込みGainブロックをmymodelシステムのVolumeという名前のブロック
% にコピーし、Gainパラメータに値4を割り当てます。
%
% す。　block = add_block('vdp/Mu', 'vdp/Mu', 'MakeNameUnique', 'on')
%
% は、ブロック名'Mu'を'Mu'にコピーして、コピーを作成します。
% 'Mu'ブロックは既に存在するので、新規ブロック名は'Mu1'です。
% デフォルトは 'off' です。
%
% add_block('vdp/Inport', 'vdp/Inport2', 'CopyOption', 'duplicate')
%
% は、'vdp'の'Inport'ブロックと同じ端子番号を共有する新規ブロック'Inport2'
% を作成します。
% デフォルトは 'copy' です。
%
% 参考 : DELETE_BLOCK, SET_PARAM.


% Copyright 1990-2002 The MathWorks, Inc.
