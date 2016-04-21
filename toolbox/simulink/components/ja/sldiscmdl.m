% SLDISCMDL   連続ブロックを含むSimulinkモデルの離散化
%
% 使用法:
%    [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME)
%    [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,METHOD)
%    [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,OPTIONS)
%    [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,METHOD,CF)
%    [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,METHOD,OPTIONS)
%    [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,METHOD,CF,OPTIONS)
% ORIGBLKS     -- 連続ブロックのオリジナルの名前
% NEWBLKS      -- 離散化されたブロックの新しい名前
% SYS               -- モデル名
% METHOD        -- 'zoh', 'foh', 'tustin','prewarp', 'matched'
% SAMPLETIME  -- サンプル時間、または [sampletime offset]
% CF                  -- 臨界周波数
% OPTIONS        -- セル配列: {target,ReplaceWith,PutInto,prompt},
%   target は、以下のものから選択可能:
% 	 'all'          --すべての連続ブロックの離散化
% 	 'selected' --SYS 内のフルパス名でのみ選択されたブロックの離散化
%   ReplaceWith は、以下のものから選択可能:
%  	'parammask' --パラメトリックなマスクである連続ブロックの置換
% 	'hardcoded' --ハードコーディングされた離散と等価な連続ブロック の置換
%   PutInto は、以下のものから選択可能:
% 	 'current'       --カレントモデル内に変更したものを配置 	'
% configurable' --configurableサブシステム内に変更したものを配置 	'
% untitled'       --新規のuntitledウィンドウ内に変更したものを配置	'copy'
% --オリジナルのモデルのコピー内に変更したものを配置  prompt は、以下のものか
% ら選択可能:	 'on'   --離散化情報の表示
% 	 'off'  --離散化情報の非表示
%


% Copyright 1990-2002 The MathWorks, Inc.
