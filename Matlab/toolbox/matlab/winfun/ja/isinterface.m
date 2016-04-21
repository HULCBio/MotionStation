%ISINTERFACE  COM Interfacesに対して真
% ISINTERFACE(H) は、H がCOM Interfaceの場合は真で、そうでない場合
% は偽です。
%
% 例題:
%   h=actxserver('excel.application');
%   workbooks = get(h, 'workbooks');
%   ret = isinterface(workbooks);       
%
% 参考: ISCOM, ISOBJECT, ACTXCONTROL, ACTXSERVER.

%   Copyright 1999-2002 The MathWorks, Inc.
