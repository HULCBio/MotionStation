% CAXIS   擬似カラー軸のスケーリング
% 
% CAXIS(V) は、V が2要素のベクトル [cmin cmax] の場合、MESH、PCOLOR、
% SURF のようなコマンドにより作成されるSURFACEおよびPATCHオブジェクトに、
% マニュアルの擬似カラースケーリングを設定します。cmin と cmax は、カレント
% のカラーマップの一番最初と一番最後のカラーに割り当てられます。PCOLORと
% SURFに対するカラーは、その範囲内のテーブルルックアップにより決定されます。
% 範囲外の値は、カラーマップの最初または最後に設定されます。
% 
% CAXIS('manual') は、カレントの範囲に軸のスケーリングを固定します。
% CAXIS('auto') は、軸のスケーリングを自動範囲設定に設定します。
% CAXIS 自身では、現在使われている [cmin cmax] を含む2要素の行ベクトルを出
% 力します。
% CAXIS(AX,...) は、カレントのaxesの代わりにaxes AX を使用します。
%
% CAXIS は、axesのプロパティ CLim と CLimMode を設定するM-ファイルです。
%
% 参考：COLORMAP, AXES, AXIS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:54:45 $
