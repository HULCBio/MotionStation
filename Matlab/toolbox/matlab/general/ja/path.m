% PATH   サーチパスの取得と設定
% 
% PATH自身では、MATLABのカレントのサーチパスを出力します。初期のサーチパ
% スリストはPATHDEFにより設定され、STARTUPにより特徴付けされます。
%
% P = PATHは、パスを含む文字列をPに出力します。
% PATH(P)は、Pのパスを変更します。PATH(PATH)は、パス上のディレクトリの 
% MATLAB ビューをリフレッシュし、ツールボックスでないディレクトリへの変
% 更を可視化します。
%
% PATH(P1,P2)は、2つのパスの文字列P1とP2を結合したパスに、パスを変更しま
% す。そのため、PATH(PATH,P)は、カレントのパスの後に新しいディレクトリを
% 追加し、PATH(P,PATH)は、カレントのパスの前に新しいディレクトリを追加します。
% P1またはP2が既にパス上にあれば、これらは追加されません。
%
% たとえば、つぎの文は、種々のオペレーティングシステム上で、MATLABのサー
% チパスにディレクトリを追加します。
%
%     Unix:     path(path,'/home/myfriend/goodstuff')
%     Windows:  path(path,'c:\tools\goodstuff')
%
% 参考 WHAT, CD, DIR, ADDPATH, RMPATH, GENPATH, PATHTOOL, SAVEPATH, REHASH.

% Copyright 1984-2003 The MathWorks, Inc.
