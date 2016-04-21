% AVIINFO 　AVI ファイルに関する情報
% FILEINFO = AVIINFO(FILENAME) は、AVIファイルに関する情報を含んだ
% 構造体のフィールドを出力します。FILENAME は、AVIファイル名を設定
% する文字列です。FILENAME に拡張子が含まれていない場合は、'.avi' が
% 使われます。ファイルは、カレントのワーキングディレクトリ内か、または
% MATLABパス上に存在しなければなりません。
%
% FILEINFO に関するフィールド
%   
%   Filename           - ファイル名を含む文字列
%   		      
%   FileSize           - バイト単位で表わすファイルの大きさを示す整数
%   		      
%   FileModDate        - ファイルを変更した日付を含む文字列
%   		      
%   NumFrames          - ムービー内の総フレーム数を示す整数
%   		      
%   FramesPerSecond    - 1秒間あたりの再生中のフレーム数を示す整数
%   		      
%   Width              - ピクセル単位で、AVIムービーの幅を示す整数
%   		      
%   Height             - ピクセル単位で、AVIムービーの高さを示す整数
%   		      
%   ImageType          - イメージのタイプを示す文字列：
%                     	 トゥルーカラー(RGB)には、'truecolor'
%                     	 インデックス付きイメージには、'indexed' です。
%   		      
%   VideoCompression   - AVIファイルを圧縮するために使用するコンプ
%                        レッサーを含む文字列。Microsoft Video 1, Run-
%                        Length Encoding, Cinepak, Intel Indeoでない場
%                        合は、4つのキャラクタコードを出力します。
%		      
%   Quality            - AVIファイルのビデオ品質を示す0から100までの数。
%                        大きい数字は、より高いビデオ品質を示します。
%                        一方、小さい数字は、低いビデオ品質を示します。
%                        この値は、AVI ファイルの中に常に設定されている
%                        ものでいので、正しくない場合もあります。
%                        
%   NumColormapEntries - カラーマップ内のカラーの数。トゥルーカラーイメー
%                        ジの場合は、値はゼロです。
%   
% AVIファイルがオーディオストリームを含んでいる場合、つぎのフィールド
% が FILEINFO に設定されます。
%   
%   AudioFormat      - オーディオデータを格納するために使用されるフォー
%                      マット名を含む文字列
%   
%   AudioRate        - オーディオストリームのサンプルレートをHertz単位
%                      で示す整数
%   
%   NumAudioChannels - オーディオストリーム内オーディオチャンネル数
%                      を示す整数
%   
% 参考：AVIFILE, AVIREAD.

% Copyright 1984-2004 The MathWorks, Inc.

