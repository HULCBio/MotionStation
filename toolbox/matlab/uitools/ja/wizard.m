% UIWIZARD GUI ウイザードを作成用のテンプレート
%
% INPUTS: appDataStruct: 空またはすべてのフィールドを入力したもの
%         callbackStruct: 正しい関数ポインタと共につぎのフィールドを必要
%                         とします。
%                         doCancel      - キャンセルを押すとウィンドウの
%                                         クローズを伝える
%                         doBack        - バックプレスを伝える
%                         doNext        - ネクストプレスを伝える
%                         doFinish      - フィニッシュプレスを伝える
%                         doKeyPress    - ウィンドウ全体のキープレスを伝える
%                         doPanelChange - カードパネルチェンジを伝える
%
% OUTPUTS: appDataStruct: 渡された get の中のフィールド。つぎのものが
%                         設定されます。
%                         initMessage   -
%                         cardPanel     -
%
%                         cancelButton  -
%                         backButton    -
%                         nextButton    -
%                         finishButton  -
%
%                         fontName      -
%                         fontSize      - 
%
%                         frameHandle   -
%                         HGHandle      - e.g. waitfor(appDataStruct.HGHandle)
%
%
% 参考：UIIMPORT


% Copyright 1984-2002 The MathWorks, Inc.
