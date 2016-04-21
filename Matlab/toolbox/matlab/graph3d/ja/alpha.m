% ALPHA - カレントAxis内のオブジェクトに対する Alpha プロパティを取得
% または設定
%
% ALPHA(VALUE)    - GCAのすべての子オブジェクトに関して、Alpha プロパ
% ティに VALUE を設定します。
% ALPHA(OBJECT, VALUE) - OBJECT の Alpha に VALUE を設定します。
%
% オブジェクトに対して、単一の Alpha 値を使います。
%
% ALPHA(scalar)   - Face Alpha にスカラ値を設定
% ALPHA('flat')   - Face Alpha に flat を設定
% ALPHA('interp') - Face Alpha に interp を設定(可能ならば)   
% ALPHA('texture')- Face Alpha に texture を設定(可能ならば)   
% ALPHA('opaque') - Face Alpha に 1 を設定
% ALPHA('clear')  - Face Alpha に 0 を設定
%
% オブジェクトのデータ内の各要素に対して、Alpha 値を設定します。
%
% ALPHA(MATRIX)   - Alphadata に MATRIX を設定
% ALPHA('x')      - Alphadata に x データと同じものを設定
% ALPHA('y')      - Alphadata に y データと同じものを設定
% ALPHA('z')      - Alphadata に z データと同じものを設定
% ALPHA('color')  - Alphadata にカラーデータと同じものを設定
% ALPHA('rand')   - Alphadata にランダム値を設定
%
% ALPHA('scaled') - Alphadata に scaled を設定
% ALPHA('direct') - Alphadata に direct を設定
% ALPHA('none')   - Alphadata に none を設定
%
% 参考：ALIM, ALPHAMAP
% 詳細は、"doc alpha" とタイプしてください。



% $Revision: 1.2.4.1 $ $Date: 2004/04/28 01:54:26 $
% Copyright 1984-2002 The MathWorks, Inc.
