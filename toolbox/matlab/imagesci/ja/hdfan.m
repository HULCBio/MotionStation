% HDFAN   HDF�}���`�t�@�C���A�m�e�[�V�����C���^�t�F�[�X��MATLAB�Q�[�g
%         �E�F�C
% 
% HDFAN �́AHDF�}���`�t�@�C���A�m�e�[�V����(AN)�C���^�t�F�[�X�̃Q�[�g
% �E�F�C�ł��B���̊֐����g�����߂ɂ́AHDF version 4.1r3��User's Guide��
% Reference Manual�Ɋ܂܂�Ă���AAN�C���^�t�F�[�X�ɂ��Ă̏��ɂ���
% �m���Ă��Ȃ���΂Ȃ�܂���B���̃h�L�������g�́ANational Center for 
% Supercomputing Applications (NCSA,<http://hdf.ncsa.uiuc.edu>)���瓾��
% ���Ƃ��ł��܂��B
%
% HDFAN �ɑ΂����ʓI�ȃV���^�b�N�X�́AHDFAN(funcstr,param1,param2,...)
% �ł��BHDF���C�u��������AN�֐��ƁAfuncstr �ɑ΂���L���Ȓl�́A1��1��
% �Ή����܂��B���Ƃ��΁AHDFAN('endaccess',annot_id) �́AC���C�u�����R�[��
% ANendaccess(annot_id)�ɑΉ����܂��B
%
% �V���^�b�N�X�̎g����
% --------------------
% �X�e�[�^�X�܂��͎��ʎq�̏o�͂�-1�̂Ƃ��A���삪���s�������Ƃ������܂��B
% 
% ���͕ϐ� annot_type �́A��ʓI�ɂ��̕�����̂����̂����ꂩ�ł��B
% 
%   'file_label'�A'file_desc'�A'data_label'�A'data_desc'.
%
% AN_id �́A�}���`�t�@�C���A�m�e�[�V�����C���^�t�F�[�X�̎��ʎq���Q�Ƃ��܂��B
% annot_id �́A�X�̃A�m�e�[�V�����̎��ʎq���Q�Ƃ��܂��Bhdfan('end',AN_id)
% �܂��� hdfan('endaccess',annot_id)���g���āA���ׂẴI�[�v�����Ă���
% ���ʎq�ւ̃A�N�Z�X�̏I�����m�F���Ȃ���΂Ȃ�܂���B�����łȂ���΁A
% HDF���C�u�����͂��ׂẴf�[�^�𐳏�Ƀt�@�C���ɏ����o���܂���B
% 
% �A�N�Z�X�֐�
% ------------
% �A�N�Z�X�֐��́A�C���^�t�F�[�X�����������A�A�m�e�[�V�����ւ̃A�N�Z�X��
% �I�����܂��BAN�̃A�N�Z�X�֐��ɑ΂���HDFAN�̃V���^�b�N�X�́A����
% �悤�ɂȂ�܂��B
%
%     AN_id = hdfan('start'�Afile_id)
%     �}���`�t�@�C���A�m�e�[�V�����C���^�t�F�[�X�����������܂��B
%
%     annot_id = hdfan('select'�AAN_id�Aindex�Aannot_type)
%     �^����ꂽ�C���f�b�N�X�l�ƃA�m�e�[�V�����̃^�C�v�ɂ���Ď��ʂ����
%     �A�m�e�[�V�����ɑ΂��鎯�ʎq��I�����A�o�͂��܂��B
%
%     status = hdfan('end'�AAN_id)
%     �}���`�t�@�C���A�m�e�[�V�����C���^�t�F�[�X�ւ̃A�N�Z�X���I�����܂��B
%
%     annot_id = hdfan('create'�AAN_id�Atag�Aref�Aannot_type)
%     �w�肵���^�O�ƎQ�Ɣԍ��Ŏ��ʂ����I�u�W�F�N�g�ɑ΂���f�[�^��
%     �A�m�e�[�V�������쐬���܂��Bannot_type �́A'data_label' �܂��� 
%     'data_desc' �ł��B 
%
%     annot_id = hdfan('createf'�AAN_id�Aannot_type)
%     �t�@�C���̃��x���܂��̓t�@�C���̐����̃A�m�e�[�V�������쐬���܂��B
%     annot_type �́A'file_label' �܂��� 'file_desc' �ł��B
%
%     status = hdfan('endaccess'�Aannot_id)
%     �A�m�e�[�V�����ւ̃A�N�Z�X���I�����܂��B
%
% �ǂݏo���Ə������݂Ɋւ���֐�
% ------------------------------
% �ǂݍ��݂Ə����o���Ɋւ���֐��́A�t�@�C���܂��̓I�u�W�F�N�g�̃A�m
% �e�[�V�����̓ǂݍ��݂Ə����o�����s���܂��BAN�̓ǂݍ��݂Ə����o���֐���
% �΂��� HDFAN �̃V���^�b�N�X�́A���̂悤�ɂȂ�܂��B
%
%     status = hdfan('writeann'�Aannot_id�Aannot_string)
%     �^����ꂽ�A�m�e�[�V�������ʎq�ɑΉ�����A�m�e�[�V�����������o���܂��B
%
%     [annot_string, status] = hdfan('readann', annot_id)
%     [annot_string�Astatus] = hdfan('readann'�Aannot_id�Amax_str_length)
%    �^����ꂽ�A�m�e�[�V�������ʎq�ɑΉ�����A�m�e�[�V������ǂݍ��݂܂��B
%     max_str_length �̓I�v�V�����ł��Bmax_str_length ���^����ꂽ�ꍇ�́A
%     annot_string �́Amax_str_length��蒷���Ă͂����܂���B
%
% ��ʏ��Ɋւ���֐�
% --------------------
% ��ʏ��Ɋւ���֐��́A�t�@�C�����̃A�m�e�[�V�����Ɋւ�������o�͂�
% �܂��BAN�̈�ʏ��֐��ɑ΂���HDFAN�̃V���^�b�N�X�́A���̂悤��
% �Ȃ�܂��B
%
%     num_annot = hdfan('numann'�AAN_id�Aannot_type�Atag�Aref)
%     �^����ꂽ�^�O�ƎQ�Ɣԍ��̑g���킹�ɑΉ�����A�w�肵���^�C�v�̃A�m
%     �e�[�V�����̐����擾���܂��B
%
%     [ann_list�Astatus] = hdfan('annlist'�AAN_id�Aannot_type�Atag�Aref)
%     �^����ꂽ�^�O�ƎQ�Ɣԍ��̑g���킹�ɑΉ�����A�t�@�C�����̗^����ꂽ
%     �^�C�v�̃A�m�e�[�V�����̃��X�g���擾���܂��B
%
%     length = hdfan('annlen'�Aannot_id)
%     �^����ꂽ�A�m�e�[�V�����̎��ʎq�ɑΉ�����A�A�m�e�[�V�����̒������擾
%     ���܂��B
% 
%     [nfl�Anfd�Andl�Andd�Astatus] = hdfan('fileinfo'�AAN_id)
%     AN_id�ɑΉ�����t�@�C�����́A�t�@�C�����x���A�t�@�C���̐����A�f�[�^��
%     �x���A�f�[�^�̐����̃A�m�e�[�V�������擾���܂��B
%
%     [tag�Aref�Astatus] = hdfan('get_tagref'�AAN_id�Aindex�Aannot_type)
%     �w�肵���A�m�e�[�V�����̃^�C�v�ƃC���f�b�N�X�ɑ΂���A�^�O�ƎQ�Ɣԍ���
%     �g���킹���擾���܂��B
%
%     [tag�Aref�Astatus] = hdfan('id2tagref'�Aannot_id)
%     �w�肵���A�m�e�[�V�����̎��ʎq�ɑΉ�����A�^�O�ƎQ�Ɣԍ��̑g���킹��
%     �擾���܂��B
%
%     annot_id = hdfan('tagref2id'�AAN_id�Atag�Aref)
%     �w�肵���^�O�ƎQ�Ɣԍ��̑g���킹�ɑΉ�����A�A�m�e�[�V�����̎��ʎq��
%     �擾���܂��B
%
%     tag = hdfan('atype2tag'�Aannot_type)
%     �w�肵���A�m�e�[�V�����^�C�v�ɑΉ�����A�^�O���擾���܂��B
%
%     annot_type = hdfan('tag2atype'�Atag)
%     �w�肵���^�O�ɑΉ�����A�A�m�e�[�V�����̃^�C�v���擾���܂��B
%
% �Q�l�FHDF, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:47 $
