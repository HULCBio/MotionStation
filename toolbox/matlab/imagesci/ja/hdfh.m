% HDFH   HDF H�C���^�t�F�[�X��MATLAB�Q�[�g�E�F�C
% 
% HDFH�́AHDF H�C���^�t�F�[�X�̃Q�[�g�E�F�C�ł��B���̊֐����g�����߂ɂ�
% HDF version 4.1r3��User's Guide��Reference Manual�Ɋ܂܂�Ă���AVdata
% �C���^�t�F�[�X�ɂ��Ă̏���m���Ă��Ȃ���΂Ȃ�܂���B���̃h�L����
% ���g�́ANational Center for Supercomputing Applications (NCSA�A<http:
% //hdf.ncsa.uiuc.edu>)���瓾�邱�Ƃ��ł��܂��B
%
% HDFH�ɑ΂����ʓI�ȃV���^�b�N�X�́AHDFH(funcstr,param1,param2,...)��
% ���BHDF���C�u��������H�֐��ƁAfuncstr �ɑ΂���L���Ȓl�́A1��1�őΉ���
% �܂��B���Ƃ��΁AHDFH('close',file_id) �́AC���C�u�����R�[�� 
% Hclose(file_d) �ɑΉ����܂��B
%
% �V���^�b�N�X�̎g����
% --------------------
% �X�e�[�^�X�܂��͎��ʎq�̏o�͂�-1�̂Ƃ��A���삪���s�������Ƃ������܂��B
% 
%   status = hdfh('appendable',access_id)
%   �v�f���t���\�ł��邱�Ƃ��w�肵�܂��B
%
%   status = hdfh('close',file_id)
%   �t�@�C���ւ̃A�N�Z�X�p�X���N���[�Y���܂��B
%
%   status = hdfh('deldd',file_id,tag,ref)
%   �f�[�^�̋L�q�q���X�g����^�O�ƎQ�Ɣԍ����폜���܂��B
%
%   status = hdfh('dupdd',file_id,tag,ref,old_tag,old_ref)
%
%   status = hdfh('endaccess',access_id)
%   �A�N�Z�X�̎��ʎq���������āA�f�[�^�I�u�W�F�N�g�̃A�N�Z�X���I�����܂��B
% 
%   [filename,access_mode,attach,status] = hdfh('fidinquire',file_id)
%   �w�肵���t�@�C���Ɋւ�������o�͂��܂��B
%
%   [tag,ref,offset,length,status] = hdfh('find',file_id,...
%               search_tag,search_ref,search_type,dir)
%   HDF�t�@�C�����Ō����������̃I�u�W�F�N�g�̈ʒu���w�肵�܂��B
%   sea rch_type �́A'new' �܂��� 'continue' �ł��Bdir �́A'forward' 
%   �܂���'backward' �ł��B
%
%   [data,status] = hdfh('getelement',file_id,tag,ref)
%   �w�肵���^�O�ƎQ�Ɣԍ��ɑ΂���f�[�^�̗v�f��ǂݍ��݂܂��B
%
%   [major,minor,release,info,status] = hdfh('getfileversion',file_id)
%   HDF�t�@�C���ɑ΂���o�[�W���������o�͂��܂��B
%
%   [major,minor,release,info,status] = hdfh('getlibversion')
%   �J�����g��HDF���C�u�����ɑ΂���o�[�W���������o�͂��܂��B
%
%   [file_id,tag,ref,length,offset,position,access,special,...
%                               status] = hdfh('inquire',access_id)
%   �f�[�^�̗v�f�Ɋւ���A�N�Z�X�����o�͂��܂��B
%
%   tf = hdfh('ishdf',filename)
%   �t�@�C����HDF�t�@�C�����ǂ������w�肵�܂��B
%
%   length = hdfh('length',file_id,tag,ref)
%   �^�O�ƎQ�Ɣԍ��Ŏw�肳�ꂽ�f�[�^�I�u�W�F�N�g�̒������o�͂��܂��B
%
%   ref = hdfh('newref',file_id)
%   ��ӓI�ȃ^�O�ƎQ�Ɣԍ��̑g���킹���o�͂��邽�߂ɁA�^�O�Ƌ��Ɏg�p����
%   ��Q�Ɣԍ����o�͂��܂��B
%
%   status = hdfh('nextread',access_id,tag,ref,origin)
%   �w�肵���^�O�ƎQ�Ɣԍ�����v����A���̃f�[�^�̋L�q�q���������܂��B
%   origin �́A'start' �܂��� 'current' �ł��B
%
%   num = hdfh('number',file_id,tag)
%   �t�@�C�����̃^�O�̌����o�͂��܂��B
%
%   offset = hdfh('offset',file_id,tag,ref)
%   �t�@�C�����̃f�[�^�̗v�f�̃I�t�Z�b�g���o�͂��܂��B
%
%   file_id = hdfh('open',filename,access,n_dds)
%   ���ׂẴf�[�^�̋L�q�q�u���b�N���������ɓǂݍ���ŁAHDF�t�@�C���̃A�N�Z
%   �X�p�X���o�͂��܂��B
%
%   count = hdfh('putelement',file_id,tag,ref,X)
%   �f�[�^�v�f�������o�����AHDF�t�@�C�����̊����̃f�[�^�v�f��u������
%   �܂��BX �́Auint8�̔z��łȂ���΂Ȃ�܂���B
%
%   X = hdfh('read',access_id,length)
%   �f�[�^�v�f���̂��̃Z�O�����g��ǂݍ��݂܂��B
%
%   status = hdfh('seek',access_id,offset,origin)
%   �A�N�Z�X�|�C���^���A�f�[�^�v�f���̃I�t�Z�b�g�ɐݒ肵�܂��Borigin�́A
%   'start' �܂��� 'current' �ł��B
%
%   access_id = hdfh('startread',file_id,tag,ref)
%
%   access_id = hdfh('startwrite',file_id,tag,ref,length)
%
%   status = hdfh('sync',file_id)
%
%   length = hdfh('trunc',access_id,trunc_len)
%   �w�肵���f�[�^�I�u�W�F�N�g���A�^����ꂽ�����őł��؂�܂��B
%
%   count = hdfh('write',access_id,X)
%   ���̃f�[�^�Z�O�����g���A�w�肵���f�[�^�̗v�f�ɏ����o���܂��BX�́A
%   uint8�̔z��łȂ���΂Ȃ�܂���B
%
% �T�|�[�g����Ă��Ȃ��֐�
% ---------------------
% NCSA H�C���^�t�F�[�X���̂��̊֐��́A����HDFH�ł̓T�|�[�g����Ă�
% �܂���FHcache�AHendbitaccess�AHexist�AHflushdd�AHgetbit�AHputbit�AHsetl-
% ength�AHshutdown�AHtagnewref.
% 
% �Q�l�FHDF, HDFAN, HDFDF24, HDFDFR8, HDFHD, HDFHE,
%       HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:51 $
