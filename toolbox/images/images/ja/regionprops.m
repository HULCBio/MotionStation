% REGIONPROPS �@�C���[�W�̈�̃v���p�e���̑���
% STATS = REGIONPROPS(L,PROPERTIES) �́A���x���s�� L �̒��̊e���x���t��
% �̈�ɑ΂���v���p�e�B�̏W���𑪒肵�܂��BL �̐��̐����v�f�́A�قȂ��
% ����Ӗ����܂��B���Ƃ��΁AL �̗v�f�W�����A1���������̂́A�̈�1�ɑΉ���
% 2 �̂��̂́A�̈�2�ɁA���X�A�Ή����܂��BSTATS �́A���� max(L(:)) �̍\��
% �̔z��ł��B�\���̔z��̃t�B�[���h�́APROPERTIES �Őݒ肳���悤�ɁA�e
% �̈�ɑ΂���قȂ�v���p�e�B���`���܂��B
%
% PROPERTIES �́A�J���}����؂�q�Ƃ��镶����A��������܂ރZ���z��A����
% ��'all'�A�܂��́A������'basic' �̂�����ł��\���܂���B����Ɋւ��鐳��
% ��������̏W���́A���̂��̂��܂�ł��܂��B
%
%     'Area'              'ConvexHull'    'EulerNumber'
%     'Centroid'          'ConvexImage'   'Extrema'       
%     'BoundingBox'       'ConvexArea'    'EquivDiameter' 
%     'SubarrayIdx'       'Image'         'Solidity'      
%     'MajorAxisLength'   'PixelList'     'Extent'        
%     'MinorAxisLength'   'PixelIdxList'  'FilledImage'  
%     'Orientation'                       'FilledArea'                   
%     'Eccentricity'                       
%                                                         
% �v���p�e�B������́A�啶���A�������Ɋ֌W�Ȃ��A�ȗ����ł��܂��B
%
% PROPERTIES ���A������'all' �̏ꍇ�A��q��������͂��ׂČv�Z����܂��B
% PROPERTIES ���A�ݒ肳��Ă��Ȃ��A�܂��́A������'basic'���ݒ肳��Ă���
% �ꍇ�́A���̑���'Area', 'Centroid', 'BoundingBox' ���v�Z����܂��B
%
% �N���X�T�|�[�g
% -------------
% ���͂̃��x���s�� L �́A�C�ӂ̐��l�N���X�ł��B
%
% �Q�l�F BWLABEL, BWLABELN, ISMEMBER, WATERSHED.



%   Copyright 1993-2002 The MathWorks, Inc.  
