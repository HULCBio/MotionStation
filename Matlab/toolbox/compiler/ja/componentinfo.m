% COMPONENTINFO   MATLAB Excel Builderコンポーネントに対する情報の
%                 種類及び登録
%
% COMPONENTINFO(varargin) は、0から3の間の入力を与え、コンポーネントの
% 読み込み及び使用に必要なすべての情報の登録と情報を示す構造体配列を出力
% します。
%
% componentinfo の呼び出しに対する一般的なシンタックスは以下の通りです:
%
% INFO = COMPONENTINFO([COMPONENT_NAME], [MAJOR_REV], [MINOR_REV])
%
% COMPONENT_NAME (optional) - コンポーネント名(大文字小文字を区別します)。
%                             インストールされたすべてのコンポーネントが
%                             デフォルトです。
% MAJOR_REV (optional)      - メジャーバージョンナンバー。すべての
%                             バージョンがデフォルトです。
% MINOR_REV (optional)      - マイナーバージョンナンバー。0がデフォルトです。
%
% コンポーネント名が与えられたとき、MAJOR_REV と MINOR_REV は、以下の
% ように解釈されます。:
% MAJOR_REV > 0 の場合、componentinfo は、特定の MAJOR_REV.MINOR_REV の
% 情報を出力します。
% MAJOR_REV = 0 の場合、componentinfo は、最も近いバージョンの情報を出力
% します。
% MAJOR_REV < 0 の場合、componentinfo は、すべてのバージョンの情報を出力
% します。
% コンポーネント名が与えられなかった場合、情報は、システムにインストール
% されたすべてのコンポーネントに対して出力されます。
%
% 例題:
%   INFO = COMPONENTINFO('mycomponent',1,0) - バージョン1.0の"mycomponent"
%                                             に対する情報を出力
%   INFO = COMPONENTINFO('mycomponent')     - "mycomponent"のすべての
%                                             バージョンに対する情報を出力
%   INFO = COMPONENTINFO                    - インストールされたすべての
%                                             コンポーネントに対する情報を
%                                             出力


% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2003/06/25 14:31:10 $
