% RESTOREUI   出力中で擬似ユーザインタフェースコントロールとして使用したImageを
% 削除
% 
% UicontrolsをもつFigureを印刷するとき、ユーザインタフェースオブジェクトは出力に
% は描画されません。そのため、出力内のUicontrolsに対して、内部を満たすためにIm-
% agesが作成されます。このコマンドは、これらのImageを削除します。
%
% 例題:
% 
%    pj = RESTOREUI( pj、h ); % Figure hからImagesを削除し、pjを修正
%
% 参考：PRINT, PRINTOPT, PREPAREUI, RESTORE, RESTOREUI.

%   $Revision: 1.4 $  $Date: 2002/06/17 13:33:44 $
%   Copyright 1984-2002 The MathWorks, Inc. 
