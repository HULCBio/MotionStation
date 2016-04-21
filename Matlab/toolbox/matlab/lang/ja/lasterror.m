% LASTERROR   最後のエラーメッセージと関連する情報
%
% LASTERROR は、他のエラー関連情報のようにMATLABによって与えられる最後
% のエラーメッセージを含んだ構造体を出力します。LASTERROR 構造体は、
% すくなくとも以下のフィールドを含むことが保証されます。
%
%       message    : エラーメッセージのテキスト
%       identifier : エラーメッセージのメッセージ識別子
%   
% LASTERROR(ERR) は、最後のエラーとして ERR 内に格納された情報を出力
% するために、LASTERROR 関数を設定します。ERR に対するただひとつの制限
% は、構造体でなければならないことです。上記のリスト内に現れる ERR の
% フィールド名で、欠けているフィールドに対しては、デフォルトが適切に
% 使われたものとして使用されます。(例えば、ERR が 'identifier' 
% フィールドをもたない場合、空の文字列が代わりに使われます)
%
% LASTERROR は、通常、TRY-CATCH ステートメント内の RETHROW 関数と組み
% 合わせて使われます。例えば:
%
%       try
%           do_something
%       catch
%           do_cleanup
%           rethrow(lasterror)
%       end
%
% もし、クリーンアップの操作が実際に起こったエラー内容に依存する場合、
% do_cleanup は LASTERROR タイプの入力を任意に取得することに注意して
% ください。
%
% 参照:  ERROR, RETHROW, TRY, CATCH, LASTERR.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $ $Date: 2004/04/28 01:59:12 $
