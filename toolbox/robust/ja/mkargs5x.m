% [EMSG,NAG1,XSFLAG,TS,O1,...,ON] = MKARGS5X(TYPES,INARGS) は、各 LTI オブ
% ジェクトを対応するデータ行列に拡張することで、セル-ベクトルの内容 INARGS
% ={I1,...,IM} を出力 O1,...ON に書き込みます。古くなったシステム MKSYS や
% PCK システムが存在する場合、拡張する前に LTI に変換されます。セル-ベクト
% ル TYPE は、データフォーマットを指定します。たとえば、TYPES = {'ss','tf'
% } は、リスト {I1,...,IM} の中の最初の LTI オブジェクトをそれに対応する状
% 態空間(a,b,c,d)行列に拡張し、そして、各それに続く LTI オブジェクトが(num,
% den)ベクトルに拡張されます。使用可能な値は、つぎのものです。
% 
%       TYPES      拡張                       拡張されたオブジェクト
%                  記述                       数字  & タイプ
%       'ss'   --- [a,b,c,d] = ssdata(sys)      4     行列
%       'des'  --- [a,b,c,d,e] = dssdata(sys)   5     行列 
%       'tss'  --- [a,b1,b2,c1,c2,d11,...       9     行列
%                    d12,d21,d22] state-space
%       'tdes' --- [a,b1,b2,c1,c2,d11,...      10     行列
%                    d12,d21,d22,e] descriptor
%       'tf'   --- [num,den] (SIMO only)         2     行列
%       'tfm'  --- [num,den,n,m] (MIMO)          4     分子行列、
%                                                      分母ベクトル
%                                                      n と m は、整数
%       'lti'  --- LTI (no expansion)            1     LTI  オブジェクト
%               
% NAG1 は、記述される出力 O1,...,ON の数を戻します。そして、これを超えるも
% のは、NaN で出力されます。
% 
% ある LTI オブジェクトが、INARGS の中に存在する場合、XSFLAG = 1 でその他
% の場合は、XSFLAG = 0 です。
% 
% TS は、LTI オブジェクトのサンプリング時間(デフォルトは、TS = 0 ) を出力
% します。
% 
% EMSG は、エラーメッセージを出力し、エラーがない場合は、空になります。

% Copyright 1988-2002 The MathWorks, Inc. 
