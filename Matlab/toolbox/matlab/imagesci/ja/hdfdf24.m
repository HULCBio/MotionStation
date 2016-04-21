% HDFDF24   HDF 24�r�b�g���X�^�C���[�W�C���^�t�F�[�X��MATLAB�Q�[�g�E�F�C
%
% HDFDFR8 �́AHDF24�r�b�g���X�^�C���[�W�C���^�t�F�[�X(DF24)�̃Q�[�g�E�F�C
% �ł��B���̊֐����g�����߂ɂ́AHDF version 4.1r3��User'sGuide��
% Reference Manual�Ɋ܂܂�Ă���ADF24�C���^�t�F�[�X�ɂ��Ă̏���
% �m���Ă��Ȃ���΂Ȃ�܂���B���̃h�L�������g�́ANational Center for 
% Supercomputing Applications (NCSA�A<http://hdf.ncsa.uiuc.edu>���瓾��
% ���Ƃ��ł��܂��B
%
% HDFDF24�ɑ΂����ʓI�ȃV���^�b�N�X�́AHDFDF24(funcstr,param1,param2,...)
% �ł��BHDF���C�u��������DF24�֐��ƁAfuncstr �ɑ΂���L���Ȓl�́A1��1��
% �Ή����܂��B���Ƃ��΁AHDFDF24('lastref') �́AC���C�u�����R�[��
% DF24lastref() �ɑΉ����܂��B
%
% �V���^�b�N�X�̎g����
% --------------------
% �X�e�[�^�X�܂��͎��ʎq�̏o�͂�-1�̂Ƃ��A���삪���s�������Ƃ������܂��B
% 
% HDF�́A�Ō�̎����̗v�f���ō����ɂȂ�悤��C�X�^�C���̗v�f�̏��Ԃ�
% �p���܂��BMATLAB�́AFORTRAN�X�^�C�����g���Ă���̂ŁA�ŏ��̎�����
% �v�f���ō����ɂȂ�܂��BHDFDF24�́AC�X�^�C���̏��Ԃ���MATLAB�X�^
% �C���̏��ԂɎ����I�ɕϊ����܂���B����́AHDFDF24�̎g�p���ɁAHDF
% �t�@�C������ǂݍ��񂾂�A�����o�����߂ɂ́AMATLAB�̃C���[�W�z���u
% ������K�v�����邱�Ƃ��Ӗ����Ă��܂��B�����Ȓu���́AHDFDF24('setil',...)
% �̂悤�Ȏg�p����interlace�t�H�[�}�b�g�Ɉˑ����܂��B����PERMUTE�̎g��
% ���́A�w�肵��interlace�t�H�[�}�b�g�ɏ]����HDF�z���MATLAB�z��ɕϊ�
% ���܂��B
% 
% �@�@�@RGB = permute(RGB,[3 2 1]);  'pixel' interlace
%       RGB = permute(RGB,[3 1 2]);  'line' interlace
%       RGB = permute(RGB,[2 1 3]);  'component' interlace
% 
% �����o���֐�
% ------------
% �����o���֐��́A���X�^�C���[�W�Z�b�g���쐬���A������V�����t�@�C����
% �ۑ����邩�A�����̃t�@�C���ɕt�������܂��B
%
%   status = hdfdf24('addimage',filename,RGB)
%   �t�@�C����24�r�b�g���X�^�C���[�W��t�������܂��B
%
%   status = hdfdf24('putimage',filename,RGB)
%   ���ׂĂ̊����̃f�[�^���㏑�����āA�t�@�C����24�r�b�g���X�^�C���[�W��
%   �����o���܂��B
%
%   status = hdfdf24('setcompress',compress_type,...)
%   �t�@�C���ɏ����o�������̃��X�^�C���[�W�̈��k���@��ݒ肵�܂��B
%   compress_type �́A'none', 'rle', 'jpeg', 'imcomp' �̂����ꂩ�ł��B
%   compress_type �� 'jpeg' �̏ꍇ�́A2�̒ǉ��̃p�����[�^��^���Ȃ�
%   ��΂Ȃ�܂���B�����́Aquality (0��100�̊Ԃ̃X�J��)�� force_baseline
%   (0��1�̂����ꂩ)�ł��B���̈��k�^�C�v�ł́A�ǉ��̃p�����[�^�͂���܂���B
%
%   status = hdfdf24('setdims',width,height)
%   �t�@�C���ɏ����o�������̃��X�^�C���[�W�ɑ΂��鎟����ݒ肵�܂��B
%
%   status = hdfdf24('setil',interlace)
%   �t�@�C���ɏ����o�������̃��X�^�C���[�W��interlace�`����ݒ肵�܂��B
%   interlace �́A'pixel', 'line', 'component' �̂����ꂩ�ł��B
%
%   ref = hdfdf24('lastref')
%   24�r�b�g���X�^�C���[�W�Ɋ��蓖�Ă���Ō�̎Q�Ɣԍ����o�͂��܂��B
%
% �ǂݍ��݊֐�
% ------------
% �ǂݍ��݊֐��́A�C���[�W�̎����ƃC���^�t�F�[�X�t�H�[�}�b�g�����肵�A���X�^
% �C���[�W�Z�b�g�ւ̘A���I�Ȃ��邢�̓����_���ȃA�N�Z�X��񋟂��܂��B
%
%   [width,height,interlace,status] = hdfdf24('getdims',filename)
%   ���̃��X�^�C���[�W��ǂݍ��ޑO�Ɏ������擾���܂��Binterlace �́A
%   'pixel', 'line', 'component' �̂����ꂩ�ł��B
%
%   [RGB,status] = hdfdf24('getimage',filename)
%     ����24�r�b�g���X�^�C���[�W��ǂݍ��݂܂��B
%
%   status = hdfdf24('reqil',interlace)
%   ���̃��X�^�C���[�W��ǂݍ��ޑO�ɃC���^�t�F�[�X�t�H�[�}�b�g���擾���܂��B
%   interlace �́A'pixel', 'line', 'component' �̂����ꂩ�ł��B
%
%   status = hdfdf24('readref',filename,ref)
%   �w�肵�����X�^�C���[�W�ԍ�������24�r�b�g���X�^�C���[�W��ǂݍ��݂܂��B
%
%   status = hdfdf24('restart')
%   �t�@�C�����̍ŏ���24�r�b�g���X�^�C���[�W�ɖ߂�܂��B
%
%   num_images = hdfdf24('nimages',filename)
%   �t�@�C������24�r�b�g���X�^�C���[�W�̐����o�͂��܂��B
%
%   �Q�l HDF, HDFAN, HDFDFR8, HDFH, HDFHD, HDFHE,
%        HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:48 $

