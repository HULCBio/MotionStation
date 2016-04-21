% CMINFO   このファイルで定義されたコンフィグレーションマネージャに
%          関する情報
% 
% 新規のコンフィグレーションマネージャは、そのファイル名を"allCMSupported"
% 関数にインクルードし、新規のAllInfo関数を作成することによって定義されます。
% 
% CMINFO('All')は、定義されたすべてのコンフィグレーションマネージャを出力
% します。
% CMINFO('RCS')は、RCSコンフィグレーションマネージャに対するタグを出力
% します。
% CMINFO('Tags'、currentSystem)は、ルートのブロック線図の
% "ConfigurationManager" プロパティで設定されていて、カレントにインストール
% されているコンフィグレーションマネージャに対するタグを出力します。
%
% CMINFO('Fields'、currentSystem)は、ルートのブロック線図の
% "ConfigurationManager" プロパティに設定されていて、カレントにインストール
% されているコンフィグレーションマネージャに対するフィールドを出力します。 
%
% CMINFO('Separators'、currentSystem)は、タグによって与えられた値のセパ
% レータを出力します。RCS、Visual Source Safe、PVCSに対しては、セパレータ
% は、':'および '$'です。
% 
% CMINFO('Command'、currentSystem)は、チェックインとチェックアウトの
% コマンドを出力します。
% 
% CMINFO('RCS'、'AllInfo')は、コンフィグレーションマネージャが定義された
% ときのすべての情報を出力します。


% Copyright 1984-2002 The MathWorks, Inc. 
