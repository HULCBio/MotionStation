% GETINFO   コンポーネントに関する情報を含む構造体を出力
% 
%   I=GETINFO(CRG_HALT_GEN)
%
%   I.Name          - コンポーネントの略式名
%   I.Type          - コンポーネントの一般的なカテゴリ、2文字コード
%   I.Desc          - コンポ－ネントの簡単な説明
%   I.ValidChildren - コンポ－ネントが子をもつかどうかを表示
%                     ValidChildren={logical(0)} 子をもたない
%                     ValidChildren={logical(1)} 子をもつことが可能
%   I.att           - コンポーネントの属性
%   I.attx          - コンポーネントの属性に関する情報
%   I.ref           - 参照の構造体
%   I.x             - 一時的な属性ページのハンドルの構造体





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:31:26 $
%   Copyright 1997-2002 The MathWorks, Inc.
