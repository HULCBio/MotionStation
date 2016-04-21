%REFRESHDATA プロットデータの更新
% REFRESHDATA  は、カレント figure のプロットのデータソースプロパティ
% を評価し、各プロットの対応するデータプロパティを設定します。
%
% REFRESHDATA(FIG) は、figure FIG のデータを更新します。
%
% REFRESHDATA(H) は、ハンドル H のベクトルに対して、H に指定された
% オブジェクト、または、そのオブジェクトの子のデータを更新します。
% 従って、H は、figure, axes, または plot オブジェクトハンドル を
% 含むことができます。
%
% REFRESHDATA(H,WS) は、ワークスペース WS のデータソースプロパティを
% 評価します。WS は、'caller' または 'base' になることができます。
% デフォルトのワークスペースは、'base' です。

%   Copyright 1984-2004 The MathWorks, Inc. 
