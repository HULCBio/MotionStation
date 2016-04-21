% SETXPCENV は、xPC Target 環境プロパティを設定します。
% 
% SETXPCENV は、MATLAB コマンドウインドウに、プロパティ名と xPC Target 環
% 境でサポートされているプロパティ値を表示します。
% 
% SETXPCENV(PROPERTYNAME, PROPERTYVALUE) は、xPC Target 環境に指定したプロ
% パティ PROPERTYNAME の値 PROPERTYVALUE を設定します。値がカレントのもの
% と異なっている場合、プロパティは新しい値で置き換わります。最終的には、
% updatexpcenv を使って、環境を更新します。
% 
% SETXPCENV(PROPERTYNAME1, PROPERTYVALUE1, PROPERTYNAME2, PROPERTYVALU E2,
% ...) は、一つのステートメントで、複数のプロパティを設定します。
% 
% 例題： 
%    setxpcenv('HostCommPort','COM2')
%    setxpcenv('TargetScope','Enabled','TcpIpSubnetMask',.....
%          '255.255.255.224')
% 
% 参考： GETXPCENV, UPDATEXPCENV, XPCBOOTDISK, XPCSETUP

%   Copyright 1994-2002 The MathWorks, Inc.
