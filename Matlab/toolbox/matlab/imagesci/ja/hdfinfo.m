% HDFINFO HDF 4 �܂��� HDF-EOS 2 �t�@�C���Ɋւ�����
%
% FILEINFO = HDFINFO(FILENAME) �́AHDF�t�@�C���܂���HDF-EOS�t�@�C
% ���̓��e�Ɋւ�������܂ލ\���̂̃t�B�[���h���o�͂��܂��BFILENAME ��
% HDF�t�@�C���̖��O���w�肷�镶����ł��BHDF-EOS�t�@�C���́AHDF�t�@�C
% ���Ƃ��ċL�q����܂��B
%
% FILEINFO = HDFINFO(FILENAME,MODE) �́AMODE 'hdf'�̏ꍇ��HDF�t�@
% �C���Ƃ��ēǂݍ��݁AMODE �� 'eos'�̏ꍇ��HDF-EOS�t�@�C���Ƃ��ăt�@
% �C����ǂݍ��݂܂��BMODE �� 'eos' �̏ꍇ�́AHDF-EOS�f�[�^�I�u�W�F�N�g
% �݂̂��Q�Ƃ���܂��B�n�C�u���b�hHDF-EOS�t�@�C���̂��ׂĂ̓��e�Ɋւ���
% ����ǂݍ��ނ��߂ɂ́AMODE ���f�t�H���g�� 'hdf' �ɐݒ肷��K�v������
% �܂��B
%   
% FILEINFO ���̃t�B�[���h�̐ݒ�́A�X�̃t�@�C���Ɉˑ����܂��BFILEINFO 
% �\���̂ɑ��݂���\���̂���t�B�[���h�́A���̂��̂ł��B
%
% HDF �I�u�W�F�N�g�F
%   
%   Filename   �t�@�C�������܂ޕ�����
%   
%   Vgroup     Vgroups���L�q����\���̂̔z��
%   
%   SDS        Scientific Data Sets���L�q����\���̔z��
%   
%   Vdata      Vdata sets���L�q����\���̔z��
%   
%   Raster8    8-bit Raster Images���L�q����\���̔z��
%   
%   Raster24   24-bit Raster Images���L�q����\���̔z��
%   
%   HDF-EOS�I�u�W�F�N�g�F
%
%   Point      HDF-EOS Point data���L�q����\���̔z��
%   
%   Grid       HDF-EOS Grid data���L�q����\���̔z��
%   
%   Swath      HDF-EOS Swath data���L�q����\���̔z��
%   
%   ��̃f�[�^�Z�b�g�\���̂́A�������̋��ʂ̃t�B�[���h�����L���Ă��܂�
%   (���̂��̂ł����A���ׂĂ̍\���̂�����炷�ׂẴt�B�[���h��������
%   ����킯�ł͂���܂���)�B
%   
%   Filename          �t�@�C�������܂ޕ�����
%                     
%   Type              HDF�I�u�W�F�N�g�^�C�v���L�q���镶����
%   	              
%   Name              �f�[�^�Z�b�g�����܂ޕ�����
%                     
%   Attributes        �f�[�^�Z�b�g�̑������ƒl���L�q����t�B�[���h 'Name'
%                     �� 'Value' �����\���̔z��
%                     
%   Rank              �f�[�^�Z�b�g�̎�������ݒ肷�鐔
%
%   Ref               �f�[�^�Z�b�g�̎Q�Ɣԍ�
%
%   Label             Annotation���x�����܂ރZ���z��
%
%   Description       Annotation�L�q���܂ރZ���z��
%
%   �e�\���̌ŗL�̃t�B�[���h�F
%   
%   Vgroup:
%   
%      Class      �f�[�^�Z�b�g�̃N���X�����܂ޕ�����
%
%      Vgroup     Vgroups���L�q����\���̔z��
%                 
%      SDS        Scientific Data sets���L�q����\���̔z��
%                 
%      Vdata      Vdata sets���L�q����\���̔z��
%                 
%      Raster24   24-bit raster images���L�q����\���̔z�� 
%                 
%      Raster8    8-bit raster images���L�q����\���̔z��
%                 
%      Tag        ����Vgroups�̃^�O
%                 
%   SDS:
%              
%      Dims       �t�B�[���h 'Name', 'DataType', 'Size', 'Scale', 'Attributes' 
%                 �����\���̔z��B�f�[�^�Z�b�g�̎������L�q���܂��B
%                 'Scale' �́A�f�[�^�Z�b�g�̒��̕����Ԋu�⎟���ɉ�����
%                 �z�u���鐔�̔z��ł��B
%              
%      DataType   �f�[�^�̐��x���w�肷�镶����
%              
%
%      Index      SDS�̃C���f�b�N�X���������l
%   
%   Vdata:
%   
%      DataAttributes    �f�[�^�Z�b�g�S�̂̑������ƒl���L�q����t�B�[���h
%                        'Name' �� 'Value' �����\���̔z��
%   
%      Class             �f�[�^�Z�b�g�̃N���X�����܂ޕ�����
%		      
%      Fields            Vdata�̃t�B�[���h���L�q����t�B�[���h 'Name' 
%                        �� 'Attributes'�����\���̔z��
%                        
%      NumRecords        �f�[�^�Z�b�g�̃��R�[�h�����w�肷�鐔
%                        
%      IsAttribute       Vdata�������̏ꍇ1�A���̑��̏ꍇ0
%      
%   Raster8 �� Raster24�F
%
%      Name           �C���[�W�����܂ޕ�����
%   
%      Width          �s�N�Z���P�ʂŕ\�킵���C���[�W�̕����w�肷�鐮��
%      
%      Height         �s�N�Z���P�ʂŕ\�킵���C���[�W�̍������w�肷�鐮��
%      
%      HasPalette     �C���[�W���p���b�g�Ɋ֘A���Ă���ꍇ1�A���̑��̏ꍇ0
%      					(8�r�b�g�̂�)
%
%      Interlace      �C���[�W�̃C���^���[�X���[�h���L�q���镶����
%                     (24�r�b�g�̂�)
%
%   Point:
%
%      Level          �t�B�[���h 'Name', 'NumRecords', 'FieldNames', 
%                     'DataType', 'Index' �����\���́B���̍\���̂́A
%                     Point �̊e���x�����L�q���܂��B
%      
%   Grid:
%     
%      UpperLeft      ���[�g���P�ʂŁA������̈ʒu���w�肷�鐔
%      
%      LowerRight     ���[�g���P�ʂŁA�E�����̈ʒu���w�肷�鐔
%      
%      Rows           Grid���̍s�����w�肷�鐮��
%      
%      Columns        Grid���̗񐔂��w�肷�鐮��
%      
%      DataFields     �t�B�[���h 'Name', 'Rank', 'Dims', 'NumberType', 
%                     'FillValue', 'TileDims' �����\���̔z��B�e�\��
%                     �̂́AGrid �̒��� Grid �t�B�[���h�̃f�[�^�t�B�[��
%                     �h���L�q���܂��B
%      
%      Projection     �t�B�[���h 'ProjCode', 'ZoneCode', 'SphereCode', 
%                     'ProjParam' �����\���̔z��BGrid �� Projection 
%                      Code, Zone Code, Sphere Code �Ⓤ�e�p�����[�^��
%                      �L�q���܂��B
%      
%      Origin Code    Grid �ɑ΂���I���W�i���R�[�h���w�肷�鐔�l
%      
%      PixRegCode     �s�N�Z���̃��W�X�g���[�V�����R�[�h���w�肷�鐔�l
%      
%   Swath:
%		       
%      DataFields     �t�B�[���h'Name', 'Rank', 'Dims', 'NumberType', 
%                     'FillValue' �����\���̂̔z��B�e�\���̂́A
%                      Swath �̒���Data �t�B�[���h���L�q���܂��B
%
%      GeolocationFields  �t�B�[���h 'Name', 'Rank', 'Dims', 'Number-
%                         Type', 'FillValue' �����\���̂̔z��B�e�\
%                         ���̂́ASwath �̒��� Geolocation �t�B�[���h
%                         ���L�q���܂��B
%   
%      MapInfo            �f�[�^�� geolocation �t�B�[���h�Ԃ̊֌W���L�q
%                         ����t�B�[���h 'Map', 'Offset', 'Increment' ��
%                         ���\���́B
%   
%      IdxMapInfo         geolocation �}�b�s���O�̃C���f�b�N�X�t���v�f��
%                         �̊֘A���L�q���� 'Map' �� 'Size' �����\����
%   
% 
% ���F  
%             % example.hdf �Ɋւ�����̓ǂݍ���
%             fileinfo = hdfinfo('example.hdf');
%             % ���� Scientific Data Set �Ɋւ�����̓ǂݍ���
%             data_set_info = fileinfo.SDS;
%	     
% �Q�l : HDFTOOL, HDFREAD, HDF.  


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:55 $    

