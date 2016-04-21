% PREPAREUI   出力にUicontrolオブジェクトを描画
% Imageに似たユーザインタフェースオブジェクトで、出力に表示されます。ユーザイン
% タフェースオブジェクトのスクリーンキャプチャを使い、ユーザインタフェースオブジ
% ェクトと同じ位置にトゥルーカラーImageを作成するので、uicontrol自身が印刷するよ
% うに見えます(MATLABではなくウィンドウシステムによって描画されるため、uicontrol
% は印刷しません)。
%
% 例題:
% 
%    pj = PREPAREUI( pj、h ); % PrintJobオブジェクトpjを修正し、Figure hにUico-
%    ntrolのImageを作成
%
% 参考：PREPARE, RESTORE, PREPAREHG, RESTOREUI.

%   $Revision: 1.4 $  $Date: 2002/06/17 13:33:50 $
%   Copyright 1984-2002 The MathWorks, Inc. 
