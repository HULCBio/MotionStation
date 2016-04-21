% SLUIGEOM   uicontrolの幅と高さの調整
%
% SLUIGEOM は、引数を指定しないと、カレントのプラットフォームの各コント
% ロールが取る余分なスペース量を出力します。たとえば、文字列が10ピクセル幅
% の場合、その文字列をチェックボックスに設定するには、チェックボックスは
% 10 + dxピクセル幅でなければなりません。
%
% 例題:
%     geom  =  sluigeom;
%     stringWidth    =  10;
%     stringHeight   =  16;
%     controlWidth   =  stringWidth  + geom.checkbox(3);
%     controlHeight  =  stringHeight + geom.checkbox(4);
%     pos  =  [8 8 controlWidth controlHeight];
%     uicontrol('string',str,'style','checkbox','pos',pos);
%
% この関数は、サポートされているすべてのプラットフォームにおいて、整合性
% のある UIの作成に役立ちます。たとえば、フォントサイズが10のPC上の
% エディットコントロールは、w * h ピクセルである必要があります。XWindows
% (フォントサイズが10)では、エディットコントロールは、XWindowsがエディット
% コントロールの端に配置する斜めのエッジのために、w + dw * h + dh である
% 必要があります。この関数は、dw と dh を出力します。


%   Copyright 1990-2002 The MathWorks, Inc.
