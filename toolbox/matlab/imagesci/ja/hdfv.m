% HDFV   HDF Vgroup�C���^�t�F�[�X��MATLAB�Q�[�g�E�F�C
% 
% HDFV�́AHDF Vgroup(V)�C���^�t�F�[�X�̃Q�[�g�E�F�C�ł��B���̊֐����g��
% ���߂ɂ́AHDF version 4.1r3��User's Guide��Reference Manual�Ɋ܂܂��
% ����AAN�C���^�t�F�[�X�ɂ��Ă̏���m���Ă��Ȃ���΂Ȃ�܂���B����
% �h�L�������g�́ANational Center for Supercomputing Applications (NCSA�A
% <http://hdf.ncsa.uiuc.edu>)���瓾�邱�Ƃ��ł��܂��B
%
% HDFV�ɑ΂����ʓI�ȃV���^�b�N�X�́AHDFV(funcstr,param1,param2,...) ��
% ���BHDF���C�u��������V�֐��ƁAfuncstr �ɑ΂���L���Ȓl�́A1��1�őΉ���
% �܂��B���Ƃ��΁AHDFV('nattrs',vgroup_id) �́AC���C�u�����R�[�� 
% Vnattrs(vgroup_id) �ɑΉ����܂��B
%
% �V���^�b�N�X�̎g����
% --------------------
% �X�e�[�^�X�܂��͎��ʎq�̏o�͂�-1�̂Ƃ��A���삪���s�������Ƃ������܂��B
% 
% �A�N�Z�X�Ɋւ���֐�
% --------------------
% �A�N�Z�X�Ɋւ���֐��́A�t�@�C�����I�[�v�����AVgroup�C���^�t�F�[�X��
% ���������A�X�̃O���[�v�ɃA�N�Z�X���܂��B�����́Avgroup��Vgroup
% �C���^�t�F�[�X�ւ̃A�N�Z�X���I�����AHDF�t�@�C�����N���[�Y���܂��B
%
%   status = hdfv('start',file_id)
%   V�C���^�t�F�[�X�����������܂��B
%
%   vgroup_id = hdfv('attach',file_id,vgroup_ref,access)
%   vgroup�ւ̃A�N�Z�X���s���܂��Baccess�́A'r' �܂��� 'w' �ł��B
%
%   status = hdfv('detach',vgroup_id)
%   vgroup�ւ̃A�N�Z�X���I�����܂��B
%
%   status = hdfv('end',file_id)
%   V�C���^�t�F�[�X�ւ̃A�N�Z�X���I�����܂��B
%
% �쐬�Ɋւ���֐�
% ----------------
% �쐬�Ɋւ���֐��́Avgroup�Ƀf�[�^�O���[�v��g�D���A���x����t���A
% �f�[�^�I�u�W�F�N�g��ǉ����܂��B
%
%   status = hdfv('setclass',vgroup_id,class)
%   vgroup�ɃN���X�����蓖�Ă܂��B
%
%   status = hdfv('setname',vgroup_id,name)
%   vgroup�ɖ��O�����蓖�Ă܂��B
%
%   ref = hdfv('insert',vgroup_id�Aid)
%   �����̃O���[�v��vgroup�܂���vdata��ǉ����܂��Bid �́Avdata��id
%   �܂���vgroup��id�ł��B
%
%   status = hdfv('addtagref',vgroup_id,tag,ref)
%   ������vgroup��HDF�f�[�^�I�u�W�F�N�g��ǉ����܂��B
%
%  status = hdfv('setattr',vgroup_id,name,A)
%   vgroup�̑�����ݒ肵�܂��B
%
% �t�@�C���̏��Ɋւ���֐�
% --------------------------
% �t�@�C���̏��Ɋւ���֐��́Avgroup�̃t�@�C���ւ̕ۑ����@�Ɋւ���
% �����o�͂��܂��B�����́Avgroup���t�@�C���ɔz�u���邽�߂ɕ֗���
% ���@�ł��B
%
%   [refs,count] = hdfv('lone',file_id,maxsize)
%   ����vgroup�Ɋ܂܂�Ă��Ȃ�vgroup�̎Q�Ɣԍ����o�͂��܂��B
%
%   next_ref = hdfv('getid',file_id,vgroup_ref)
%   HDF�t�@�C�����̂���vgroup�ɑ΂���Q�Ɣԍ����o�͂��܂��B
%
%   vgroup_ref = hdfv('findclass',file_id,class)
%   �w�肵���N���X������Vgroup�̎Q�Ɣԍ����o�͂��܂��B
%
% Vgroup�̏��Ɋւ���֐�
% ------------------------
% Vgroup�̏��Ɋւ���֐��́A�����vgroup�Ɋւ��Ďw�肵�������
% ���܂��B���̏��́A�N���X�A���O�A�����o���A�t���I�ȃ����o�̏���
% �܂݂܂��B
%
%   [class_name,status] = hdfv('getclass',vgroup_id)
%   �w�肵���O���[�v�̃N���X���o�͂��܂��B
%
%   [vgroup_name,status] = hdfv('getname',vgroup_id)
%   �w�肵���O���[�v�����o�͂��܂��B
%
%   status = hdfv('isvg',vgroup_id,ref)
%   vgroup�̎��ʎq���Avgroup����vgroup�ɑ����邩�ǂ������`�F�b�N���܂��B
%   ref �́Avdata�܂���vgroup�̎Q�Ɣԍ��ł��B
%
%   status = hdfv('isvs',vgroup_id,vdata_ref)
%   vdata�̎��ʎq���Avgroup����vdata�ɑ����邩�ǂ������`�F�b�N���܂��B
%
%   [tag,ref,status] = hdfv('gettagref',vgroup_id,index)
%   �w�肵��vgroup���̃f�[�^�I�u�W�F�N�g�ɑ΂���A�^�O�ƎQ�Ɣԍ��̑g���킹
%   ���擾���܂��B
%
%   count = hdfv('ntagrefs',vgroup_id)
%   �w�肵��vgroup���Ɋ܂܂��^�O�ƎQ�Ɣԍ��̑g���킹���o�͂��܂��B
%
%   [tag,refs,count] = hdfv('gettagrefs',vgroup_id,maxsize)
%   vgroup���̂��ׂẴf�[�^�I�u�W�F�N�g�́A�^�O�ƎQ�Ɣԍ��̑g���킹��
%   �擾���܂��B
% 
%   tf = hdfv('inqtagref',vgroup_id,tag,ref)
%   �I�u�W�F�N�g���Avgroup�ɑ����邩�ǂ������`�F�b�N���܂��B
%
%   version = hdfv('getversion',vgroup_id)
%   �^����ꂽvgroup�̃o�[�W�������m�F���܂��B
%
%   count = hdfv('nattrs',vgroup_id)
%   vgroup�̑����̑������m�F���܂��B
%
%   [name,data_type,count,nbytes,status] = ....
%                hdfv('attrinfo',vgroup_id,attr_index)
%   �^����ꂽvgroup�̑����Ɋւ�������m�F���܂��B
%
%   [values,status] = hdfv('getattr',vgroup_id,attr_index)
%   �^����ꂽ�����̒l���m�F���܂��B
%
%   ref = hdfv('Queryref',vgroup_id)
%   �w�肵��vgroup�̎Q�Ɣԍ����o�͂��܂��B
%
%   tag = hdfv('Querytag',vgroup_id)
%   �w�肵��vgroup�̃^�O���o�͂��܂��B
%
%   vdata_ref = hdfv('flocate',vgroup_id,field)
%   �w�肵��vgroup���Ŏw�肵���t�B�[���h�����܂�vdata�̎Q�Ɣԍ����o��
%   ���܂��B
%
%   count = hdfv('nrefs',vgroup_id,tag)
%   �w�肵��vgroup���Ŏw�肵���^�O�����f�[�^�I�u�W�F�N�g�����o�͂��܂��B
% 
% �Q�l�FHDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFML, HDFSD, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:02 $
