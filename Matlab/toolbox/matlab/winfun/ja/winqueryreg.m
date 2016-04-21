% WINQUERYREG   Microsoft Windowsレジストリからアイテムの取得
% 
% VALUE = WINQUERYREG(ROOTKEY, SUBKEY, VALNAME) は、指定されたキーの値
% を返します。
%
% VALUE = WINQUERYREG(ROOTKEY, SUBKEY) は、名前プロパティを持たない値
% を返します。
%
% VALUE = WINQUERYREG('name',...) は、セル配列の ROOTKEY\SUBKEY 内の
% キーの名前を返します。
%
% 例題: 
% 
%     winqueryreg HKEY_CURRENT_USER Environment HOME
%     winqueryreg HKEY_CURRENT_USER Environment USER
%     winqueryreg HKEY_LOCAL_MACHINE SOFTWARE\Classes\.zip
%     winqueryreg HKEY_CURRENT_USER Environment path
%     winqueryreg name HKEY_CURRENT_USER Environment
%
% 
% この関数は、つぎのレジストリの値のタイプに対してのみ機能します。
%
%    文字列 (REG_SZ)
%    拡張文字列 (REG_EXPAND_SZ)
%    32-bit 整数 (REG_DWORD)
%
% 指定された値が文字列の場合、関数は文字列を返します。値が32-bit 整数の
% 場合は、MATLABのint32タイプの整数を返します。


%   Copyright 1984-2002 The MathWorks, Inc. 
