% PRINTDLG   プリントダイアログボックス
% 
% PRINTDLG(FIG) は、figureウィンドウ FIG を印刷するためのダイアログボックス
% を作成します。uimenuは印刷されません。PRINTDLG は、gcfを印刷します。
%
% PRINTDLG('-crossplatform',FIG) は、PC用の組み込みの印刷ダイアログでは
% なく、標準のクロスプラットフォームMATLAB印刷ダイアログを強制的に表示
% します。このオプションは、他のオプションの前に挿入されます。
%
% PRINTDLG('-setup',FIG) は、セットアップモードで、印刷ダイアログを強制的
% に表示します。ここでは、実際に印刷しないで、デフォルトの印刷オプション
% を設定することができます。


%  Loren Dean
%  Copyright 1984-2002 The MathWorks, Inc. 
%  $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:08:40 $
