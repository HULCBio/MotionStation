% HDFVH   HDF Vdata�C���^�t�F�[�X��VH�֐���MATLAB�Q�[�g�E�F�C
% 
% HDFVF�́AHDF Vdata�C���^�t�F�[�X����VH�֐��̃Q�[�g�E�F�C�ł��B���̊�
% �����g�����߂ɂ́AHDF version 4.1r3��User's Guide��Reference Manual��
% �܂܂�Ă���AVdata�C���^�t�F�[�X�ɂ��Ă̏���m���Ă��Ȃ���΂Ȃ��
% ����B���̃h�L�������g�́ANational Center for Supercomputing 
% Applications (NCSA�A<http://hdf.ncsa.uiuc.edu>)���瓾�邱�Ƃ��ł��܂��B
%
% HDFVH�ɑ΂����ʓI�ȃV���^�b�N�X�́AHDFVH(funcstr,param1,param2,...)
% �ł��BHDF���C�u��������V�֐��ƁAfuncstr �ɑ΂���L���Ȓl�́A1��1�őΉ�
% ���܂��B
%
% �V���^�b�N�X�̎g����
% --------------------
% �X�e�[�^�X�܂��͎��ʎq�̏o�͂�-1�̂Ƃ��A���삪���s�������Ƃ������܂��B
%
% ����vdata_class�́AHDF���l�^�C�v���`���镶����ł��B���̂��̂��g
% �p�ł��܂��B
% 
%    'uchar8', 'uchar', 'char8', 'char', 'double', 'uint8', 'uint16', 
%    'uint32', 'float', 'int8', 'int16', 'int32'
% 
% ������Vdata�Ɋւ���֐�
% -----------------------
% ������Vdata�Ɋւ���֐��́A�f�[�^��P��̃t�B�[���h��vdata�ɏ����o����
% ���B
%
%   vgroup_ref = ....
%      hdfvh('makegroup',file_id,tags,refs,vgroup_name,vgroup_class)
%   vgroup���̃f�[�^�I�u�W�F�N�g�̏W�����O���[�v�����܂��B
%
%   count = ....
%     hdfvh('storedata',file_id,fieldname,data,vdata_name,vdata_class)
%   1�̃t�B�[���h�݂̂������R�[�h���܂�vdata���쐬���܂��B�t�B�[���h��
%   ��1�̗v�f���܂݂܂��B
%   ���ӁF�f�[�^�̃N���X�́AHDF���l�^�C�vvdata_class�ƈ�v���Ȃ���΂Ȃ��
%   ����BMATLAB������́AHDF char�^�C�v�̂����ꂩ�Ɉ�v����悤�Ɏ���
%   �I�ɕϊ�����܂��B���̃f�[�^�^�C�v�͌����ȈӖ��ŁA��v���Ȃ���΂Ȃ�
%   �܂���B
%
%   count = ....
%     hdfvh('storedatam',file_id,filename,data,vdata_name,vdata_class)
%   1�̃t�B�[���h�������R�[�h���܂�vdata���쐬���܂��B�t�B�[���h�́A�P
%   ���܂��͕����̗v�f���܂݂܂��B���ӁF�f�[�^�̃N���X�́AHDF���l�^�C
%   �vvdata_class�ƈ�v���Ȃ���΂Ȃ�܂���BMATLAB�̕�����́AHDF char
%   �^�C�v�̂����ꂩ�Ɉ�v����悤�Ɏ����I�ɕϊ�����܂��B���̃f�[�^�^�C�v
%   �͌����ȈӖ��ŁA��v���Ȃ���΂Ȃ�܂���B
%
% �Q�l�FHDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFML, HDFSD, HDFV, HDFVF, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:04 $
