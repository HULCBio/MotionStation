function noselection( state, fig )
%NOSELECTION   Figure内のすべてのオブジェクトの選択/非選択
%   NOSELECTION SAVEは、Selectedプロパティが'on'であるすべてのオブジェクトを求
%   めます。そしてそれら全てを'off'にします。Selectedの値がリストアされるように
%   ハンドルを保存します。これは印刷時に有効なので、selectionハンドルは印刷しま
%   せん。
%
%   NOSELECTION RESTOREは、前もって変更されたオブジェクトのSelectedプロパティ
%   を、元の値に戻します。
%
%   NOSELECTION(...,FIG)は、指定したfigureに対して操作します。
%
%   参考   PRINT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/06/17 13:33:37 $
