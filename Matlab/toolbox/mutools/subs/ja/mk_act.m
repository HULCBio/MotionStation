%-------------------------- mk_act --------------------%
%
% これは、資料内で指定されたような2アクチュエータモデルを作成します。各
% 々のアクチュエータモデルは、1入力3 出力です。これらは、つぎのように記
% 述されます。
%
%  ACTRUD:  4状態、3出力、1入力
%          出力:	      入力:
%          1) position	      1) rudder_cmd
%          2) rate
% 	   3) acceleration
%
%  ACTELE:  4状態、3出力、1入力
%         出力:              入力:
%          1) position       1) elevon_cmd
%          2) rate
%          3) acceleration

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:31:23 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
