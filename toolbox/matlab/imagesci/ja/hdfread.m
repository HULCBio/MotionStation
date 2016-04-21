% HDFREAD   HDF �t�@�C������f�[�^�𒊏o
%   
% HDFREAD �́AHDF�܂���HDF-EOS �t�@�C���̒��̃f�[�^�Z�b�g����f�[�^
% ��ǂݍ��݂܂��B�f�[�^�Z�b�g�̖��O�����m�̏ꍇ�AHDFREAD �́A�f�[�^����
% �ރt�@�C�����T�[�`���܂��B���̑��̏ꍇ�AHDFINFO ���g���āA�t�@�C���̓�
% �e���L�q����\���̂𓾂邱�Ƃ��ł��܂��BHDFINFO �ŏo�͂����\���̂̃t
% �B�[���h�́A�t�@�C���̒��Ɋ܂܂��f�[�^�Z�b�g���L�q����\���̂ł��B
% �f�[�^�Z�b�g���L�q����\���̂����o����A���ځAHDFREAD �ɓn����܂��B��
% ���̃I�v�V�����́A���ɏڍׂ��L���Ă��܂��B
%   
% DATA = HDFREAD(FILENAME,DATASETNAME) �́ADATASETNAME �Ɩ��t��
% ���f�[�^�Z�b�g�ɑ΂��āA�t�@�C�� FILENAME ����ϐ� DATA �ɁA���ׂẴf�[
% �^���o�͂��܂��B
%   
% DATA = HDFREAD(HINFO) �́AHINFO �ɂ��L�q��������̃f�[�^�Z�b�g��
% �΂��āA�t�@�C������ϐ� DATA �ɂ��ׂẴf�[�^���o�͂��܂��BHINFO �́A
% HDFINFO �̏o�͍\���̂��璊�o���ꂽ�\���̂ł��B
%   
% DATA = HDFREAD(...,PARAMETER,VALUE,PARAMETER2,VALUE2...) �́A�T�u
% �Z�b�g�̃^�C�v�Ƃ��̒l VALUE ���w�肷�镶���� PARAMETER �ɏ]���āA�f�[
% �^�𕪗ނ��܂��B���̕\�́A�f�[�^�Z�b�g�̊e�^�C�v�ɑ΂��鐳�����T�u�Z�b�g
% �̃p�����[�^�̊T�v�����������̂ł��B'required' �ƃ}�[�N�����p�����[�^�́A
% �f�[�^�Z�b�g�̒��ɃX�g�A���ꂽ�f�[�^��ǂݍ��ނ��߂Ɏg���܂��B
% "exclusive" �ƃ}�[�N�����p�����[�^�́A�K�v�ȃp�����[�^�������āA���̃T�u
% �Z�b�g�p�����[�^�Ƌ��Ɏg�����Ƃ͂���܂���B�p�����[�^�������l��K�v�Ƃ�
% ��ꍇ�A�l�́A�Z���z��ɃX�g�A�����K�v������܂��B�p�����[�^�ɑ΂���
% �K�v�Ȓl�̐��́A�f�[�^�Z�b�g�̃^�C�v�Ƌ��ɕω����܂��B�����̈Ⴂ�́A
% �p�����[�^�̋L�q�̒��ɋL�q����Ă��܂��B
%
% [DATA,MAP] = HDFREAD(...) �́A8�r�b�g���X�^�C���[�W�ɑ΂��āA�C���[�W
% �f�[�^�ƃJ���[�}�b�v���o�͂��܂��B
%   
% �g�p�\�ȃT�u�Z�b�g�p�����[�^�̕\
%
%
%           �f�[�^�Z�b�g      |   �T�u�Z�b�g�p�����[�^
%          ========================================
%           HDF Data          |
%                             |
%             SDS             |   'Index'
%                             |
%             Vdata           |   'Fields'
%                             |   'NumRecords'
%                             |   'FirstRecord'
%          ___________________|____________________
%           HDF-EOS Data      |   
%                             |
%             Grid            |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Tile'           (exclusive)
%                             |   'Interpolate'    (exclusive)
%                             |   'Pixels'         (exclusive)
%                             |   'Box'
%                             |   'Time'
%                             |   'Vertical'
%                             |
%             Swath           |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Time'           (exclusive)
%                             |   'Box'
%                             |   'Vertical'
%                             |   'ExtMode'
%                             |
%             Point           |   'Level'          (required)
%                             |   'Fields'         (required)
%                             |   'RecordNumbers'
%                             |   'Box'
%                             |   'Time'
%
% Raster Image�p�̃T�u�Z�b�g�p�����[�^�͂���܂���B
%
%
% �������p�����[�^�Ƃ��̒l�́A�ȉ��̒ʂ�ł��B
%
%   'Index' 
%   'Index'�ɑ΂���l�F START, STRIDE, EDGE
%
% START, STRIDE, EDGE �́A�������Ɠ������T�C�Y�����z��łȂ���΂Ȃ��
% ����BSTART �́A�f�[�^�Z�b�g�̒��ŁA�ǂݎn�߂�ʒu���w�肵�܂��BSTART 
% �ɐݒ肳�ꂽ���ꂼ��̐��́A�Ή����鎟�������������K�v������܂��B
% STRIDE �́A�ǂݍ��ޒl�̊Ԃ̊Ԋu���w�肷��z��ł��BEDGE �́A�ǂݍ���
% �e�����̒������w�肷��z��ł��BSTART, STRIDE, EDGE �Ŏw�肵���̈�
% �́A�f�[�^�Z�b�g�̎����ɏ������܂�܂��BSTART, STRIDE, EDGE �̂����ꂩ
% ����̏ꍇ�́A�f�t�H���g�l�͂��̉���̂��ƂŌv�Z����܂��B�e�����̍�
% ���̗v�f�ŃX�^�[�g���A1�� STRIDE �ŁA�����̃X�^�[�g�_����I���_�܂ł�
% �ǂނ悤�� EDGE ���l���܂��B�f�t�H���g�́ASTART, STRIDE �ɑ΂��Ă��ׂ�
% 1�ŁAEDGE �͑Ή����鎟���̒������܂ޔz��ł��BSTART, STRIDE, EDGE 
% �́A����1���x�[�X�ɂ��Ă��܂��BSTART, STRIDE, EDGE �x�N�g���́A���̋L
% �@���g���āA1�̃Z���ɃX�g�A����܂��B{START,STRIDE,EDGE}
%
%   'FIELDS'
%    'Fields'�ɑ΂���l�F FIELDS
%
% �f�[�^�Z�b�g�̃t�B�[���h FIELDS ����f�[�^��ǂݍ��݂܂��BFIELDS �́A
% �P��̕�����ł��B�����̃t�B�[���h���ɑ΂��ẮA�J���}����؂�q�Ƃ���
% �g�����ꗗ���g���܂��BGrid �� Swath �f�[�^�Z�b�g�ɑ΂��ẮA������1��
% �̃t�B�[���h�݂̂̐ݒ�ō\���܂���B
%
%   'Box'
%   'Box'�ɑ΂���l�F LONG, LAT, MODE
%
% LONG �� LAT �́A�ܓx/�o�x�̈���w�肷�鐔�l�ł��BMODE �́A�̈����
% ��_�O�����܂�ł��邩�ۂ��̊���`���܂��B����̈�̒��Ɍ�_�O��
% �����݂��邩�́A���̒��ԓ_���{�b�N�X�̒��Ɋ܂܂��A���Ȃ킿�A�ǂ��炩
% �̒[�_���{�b�N�X���ɑ��݂��邩�A�܂��͔C�ӂ̓_���{�b�N�X���ɑ��݂���
% ���Ƃł��B���̂��߂ɁAMODE �� 'midpoint',  'endpoint', 'anypoint' ��ݒ肷�邱
% �Ƃ��ł��܂��BMODE �́ASwath �f�[�^�ɑ΂��Ă̂ݗL���ŁAGrid �� Point 
% �f�[�^�Z�b�g�ɑ΂��Ďw�肳���ꍇ�͖�������܂��B
%
%   'Time'
%   'Time' �ɑ΂���l�F STARTTIME, STOPTIME, MODE
%
% STARTTIME �� STOPTIME �́A���ԗ̈���w�肷�鐔�l�ł��BMODE �́A��
% ����̌�_�O�����܂�ł��邩�ۂ��̊���`���܂��B����̈�̒��Ɍ�
% �_�O�������݂��邩�́A���̒��ԓ_���{�b�N�X�̒��Ɋ܂܂��A���Ȃ킿�A��
% ���炩�̒[�_���{�b�N�X���ɑ��݂��邩�A�܂��͔C�ӂ̓_���{�b�N�X���ɑ���
% ���邱�Ƃł��B���̂��߂ɁAMODE �́A'midpoint', 'endpoint', 'anypoint' ��ݒ肷
% �邱�Ƃ��ł��܂��BMODE �́ASwath �f�[�^�ɑ΂��Ă̂ݗL���ŁAGrid �� Point 
% �f�[�^�Z�b�g�ɑ΂��Ďw�肳���ꍇ�͖�������܂��B
%
%   'Vertical'
%   'Vertical'�ɑ΂���l�FDIMENSION, RANGE
%
% RANGE �́A�T�u�Z�b�g�ɑ΂��āA�����W�̍ŏ��ƍő���w�肷��x�N�g���ł��B
% DIMENSION �́A�t�B�[���h���܂��̓T�u�Z�b�g���̎����ł��BDIMENSION 
% �������̏ꍇ�ARANGE �͒��o����v�f�̃����W(1�x�[�X)���w�肵�܂��B
% DIMENSION ���t�B�[���h�̏ꍇ�́ARANGE �͒��o����l�̃����W���w�肵��
% ���B���������̃T�u�Z�b�g�́A'Box' �܂���'Time' �ƍ��킹�ė��p����܂��B
% ���������ɉ������̈�̃T�u�Z�b�g�����s�����߁A���������̃T�u�Z�b�g�́A
% HDFREAD�ւ�1��̌Ăяo����8��܂Ŏg�����Ƃ��ł��܂��B
%
%   'ExtMode'
%   'ExtMode'�ɑ΂���l�F EXTMODE
%
% EXTMODE �́A'Internal' (�f�t�H���g)�܂��� 'External' �̂����ꂩ��ݒ肵
% �܂��B���[�h�� 'Internal' �ɐݒ肳���ꍇ�́Ageolocation �t�B�[���h��
% data �t�B�[���h�͓�����Ԃɑ��݂���K�v������܂��B���[�h�� 'External'
% �ɐݒ肳���ꍇ�́Ageolocation �t�B�[���h�� data �t�B�[���h�͈قȂ��Ԃ�
% ���݂��Ă��\���܂���B���̃p�����[�^�́A���ԋ�Ԃ܂��͗̈�𒊏o����
% �Ƃ��ɁASwath �ɑ΂��Ă̂ݎg�p������̂ł��B
%
%   'Pixels'
%   'Pixels'�ɑ΂���l�F LON, LAT
%
% LON �� LAT �́A�ܓx/�o�x�̈���w�肷�鐔���ł��B�ܓx/�o�x�ɂ��̈�
% �́A�O���b�h�̍���������_�Ƃ����s�N�Z���̍s�Ɨ�ɕϊ����邱�Ƃ��ł��܂��B
% ����́A'Box' �̈��ݒ肷����̂ƃs�N�Z���œ����ɂȂ�܂��B
%
%   'RecordNumbers'
%   'RecordNumbers'�ɑ΂���l�F: RecNums
%
% RecNums �́A�ǂݍ��ރ��R�[�h�����w�肷��x�N�g���ł��B  
%
%   'Level'
%   'Level'�ɑ΂���l�F LVL
%   
% LVL �́AHDF-EOS Point�f�[�^�Z�b�g�̒�����ǂݍ��ރ��x�����w�肷��1��
% �x�[�X�ɂ������l�ł��B
%
%   'NumRecords'
%   'NumRecords'�ɑ΂���l�F NumRecs
%
% NumRecs �́A�ǂݍ��ރ��R�[�h���̑������w�肷�鐔���ł��B
%
%   'FirstRecord'
%   'FirstRecord'�ɑ΂��ĕK�v�Ȓl�F FirstRecord
%
% FirstRecord �́A�ǂݍ��݂��J�n����ŏ��̃��R�[�h���w�肷��1���x�[�X��
% ���������ł��B
%
%   'Tile'
%   'Tile'�ɑ΂��ĕK�v�Ȓl�F TileCoords
%
% TileCoords �́A�ǂݍ��ރ^�C�����W���w�肷��x�N�g���ł��B
%
%   'Interpolate'
%   'Interpolate'�ɑ΂���l�F LON, LAT
%
% LON �� LAT �́A�o�ꎟ���}�ɑ΂��āA�w�肷��ܓx/�o�x�̓_�̐��ł��B
%
%    �Q�ƁF 
%
%    ��� 1:
%            
%             % 'Example SDS' �Ɩ��t�����f�[�^�Z�b�g��ǂݍ���
%             data = hdfread('example.hdf','Example SDS');
%
%    ��� 2:
%
%             % example.hdf �Ɋւ������ǂݍ���
%             fileinfo = hdfinfo('example.hdf');
%             % example.hdf �̒���Scientific Data Set�Ɋւ������
%               �ǂݍ���
%             data_set_info = fileinfo.SDS;
%             %  �T�C�Y�̃`�F�b�N
%             data_set_info.Dims.Size
%             % info �\���̂��g���āA�f�[�^�̃T�u�Z�b�g��ǂݍ���
%             data = hdfread(data_set_info,...
%                              'Index',{[3 3],[],[10 2 ]});
%
% �Q�l : HDFTOOL, HDFINFO, HDF.  


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:58 $
