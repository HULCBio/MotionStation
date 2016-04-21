% UIOPEN 適切なファイルフィルタを使って、ファイルの選択ダイアログを
% 表示
%
% UIOPEN は、ファイル選択ダイアログを常に表示します。ユーザは、オープン
% するファイルを選択するか、または、キャンセルをクリックするかのいずれか
% ができます。ユーザが、キャンセルをクリックすると、これ以上の挙動を行う
% ことはできません。別な方法として、OPEN コマンドは、ベースワークスペース
% 内でユーザ指定のファイル名を処理します。
%
% つぎのものは、UIOPEN を使って表示できるファイルフィルタです。
%
% Input argument       Filter リスト
% <no input args>      *.m, *.fig, *.mat,
%                      *.mdl               (Simulink がインストール
%                                           されている場合)
%                      *.cdr               (Stateflow がインストール
%                                           されている場合)
%                      *.rtw, *.tmf, *.tlc, *.c, *.h, *.ads, *.adb
%                                          (Real-Time Workshop が
%                                           インストールされている場合)
%                      *.*
% MATLAB               *.m, *.fig, *.*
% LOAD                 *.mat, *.*
% FIGURE               *.fig, *.*
% SIMULINK             *.mdl, *.*
% EDITOR               *.m,
%
% 入力引数が認識されない場合はファイルフィルタとして取り扱われ、
% UIGETFILE コマンドに直接渡されます。
%
% 参考：UIGETFILE, UIPUTFILE, OPEN, UILOAD, UIIMPORT.


% Copyright 1984-2002 The MathWorks, Inc. 
