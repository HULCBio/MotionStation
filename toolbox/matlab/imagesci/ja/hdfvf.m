% HDFVF   HDF Vdata�C���^�t�F�[�X����VF�֐���MATLAB�Q�[�g�E�F�C
% 
% HDFVF�́AHDF Vdata�C���^�t�F�[�X����VF�֐��̃Q�[�g�E�F�C�ł��B���̊�
% �����g�����߂ɂ́AHDF version 4.1r3��User's Guide��ReferenceManual�Ɋ�
% �܂�Ă���AVdata�C���^�t�F�[�X�ɂ��Ă̏���m���Ă��Ȃ���΂Ȃ�܂�
% ��B���̃h�L�������g�́ANational Center for Supercomputing Applications 
% (NCSA�A<http://hdf.ncsa.uiuc.edu>)���瓾�邱�Ƃ��ł��܂��B
%
% HDFVF�ɑ΂����ʓI�ȃV���^�b�N�X�́AHDFVF(funcstr,param1,param2,...)
% �ł��BHDF���C�u��������V�֐��ƁAfuncstr �ɑ΂���L���Ȓl�́A1��1�őΉ�
% ���܂��B���Ƃ��΁AHDFVF('nfields',vdata_id) �́AC���C�u�����R�[��
% VFnfields(vdata_id) �ɑΉ����܂��B
%
% �V���^�b�N�X�̎g����
% --------------------
% �X�e�[�^�X�܂��͎��ʎq�̏o�͂�-1�̂Ƃ��A���삪���s�������Ƃ������܂��B
% 
% �t�B�[���h�̏��Ɋւ���֐�
% ----------------------------
% �t�B�[���h�̏��Ɋւ���֐��́A�^����ꂽvdata���̃t�B�[���h�Ɋւ���
% ����񋟂��܂��B����́Avdata���̃t�B�[���h�̃T�C�Y�A�t�B�[���h���A
% �����A�^�C�v�A�t�B�[���h�̌����܂݂܂��B
%
%   fsize = hdfvf('fieldesize',vdata_id,field_index)
%   �w�肵���t�B�[���h�̃t�B�[���h�T�C�Y(�t�@�C���Ɋi�[����Ă��܂�)��
%   �擾���܂��B
% 
%   fsize = hdfvf('fieldisize',vdata_id,field_index)
%   �w�肵���t�B�[���h�̃t�B�[���h�T�C�Y(�������Ɋi�[����Ă��܂�)���擾
%   ���܂��B
%
%   name = hdfvf('fieldname',vdata_id,field_index)
%   �^����ꂽvdata���̎w�肵���t�B�[���h�����擾���܂��B
%
%   order = hdfvf('fieldorder',vdata_id,field_index)
%   �^����ꂽvdata���̎w�肵���t�B�[���h�̏��Ԃ��擾���܂��B
%
%   data_type = hdfvf('fieldtype',vdata_id,field_index)
%   �^����ꂽvdata���̎w�肵���t�B�[���h�̃f�[�^�^�C�v���擾���܂��B
%
%   count = hdfvf('nfields',vdata_id)
%   �w�肵��vdata���̃t�B�[���h�̑������擾���܂��B
%
% �Q�l�FHDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFML, HDFSD, HDFV, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:03 $
