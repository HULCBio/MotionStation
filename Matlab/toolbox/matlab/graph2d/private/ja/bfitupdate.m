% BFITUPDATE は、オープン Data Statistics GUI に対して、新しいデータセッ
% トに更新します。
% 
% [...] = BFITUPDATE(FIGH, NEWDATAHANDLE) は、カレントデータをフィギュア
% FIGH にプロットされている NEWDATAHANDLE と交換します。新しいデータに対
% する適合が計算されるか、または、新しいデータが、以前の"カレントデータ"
% であるかを調べて、XSTR と YSTR に出力します。XCHECK と YCHECK は、NE-
% WDATAHANDLE がカレントデータであった時より前に、どのチェックボックスで
% どこでチェックされたかを告げます。これらのデータ統計プロットは、再プロ
% ットされます。データ統計量がプロットした古いカレントデータが取り除かれ
% て、appdata に記録されます。

% $Revision: 1.5 $ $Date: 2002/06/17 13:32:34 $
%   Copyright 1984-2002 The MathWorks, Inc.
