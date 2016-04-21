% HDFDFR8   HDF 8�r�b�g���X�^�C���[�W�C���^�t�F�[�X��MATLAB�Q�[�g�E�F�C
% 
% HDFDFR8�́AHDF 8�r�b�g���X�^�C���[�W�C���^�t�F�[�X(DFR8)�̃Q�[�g�E�F�C
% �ł��B���̊֐����g�����߂ɂ́AHDF version 4.1r3��User's Guide��
% Reference Manual�Ɋ܂܂�Ă���ADFR8�C���^�t�F�[�X�ɂ��Ă̏���
% �m���Ă��Ȃ���΂Ȃ�܂���B���̃h�L�������g�́ANational Center for 
% Supercomputing Applications (NCSA�A<http://hdf.ncsa.uiuc.edu>)���瓾��
% ���Ƃ��ł��܂��B
%
% HDFDFR8�ɑ΂����ʓI�ȃV���^�b�N�X�́AHDFDFR8(funcstr,param1,
% param2,...)�ł��BHDF���C�u��������DFR8�֐��ƁAfuncstr �ɑ΂���L���Ȓl�́A
% 1��1�őΉ����܂��B���Ƃ��΁AHDFDFR8('setpalette',map) �́AC���C�u�����R�[
% �� DFR8setpalette(map) �ɑΉ����܂��B
%
% �V���^�b�N�X�̎g����
% --------------------
% �X�e�[�^�X�܂��͎��ʎq�̏o�͂�-1�̂Ƃ��A���삪���s�������Ƃ������܂��B
% 
% HDF�́A�Ō�̎����̗v�f���ō����ɂȂ�悤��C�X�^�C���̗v�f�̏��Ԃ�
% �p���܂��BMATLAB�́AFORTRAN�X�^�C�����g���Ă���̂ŁA�ŏ��̎�����
% �v�f���ō����ɂȂ�܂��BHDFDFR8�́AC�X�^�C���̏��Ԃ���MATLAB�X�^
% �C���̏��ԂɎ����I�ɕϊ����܂���B����́AHDFDF24�̎g�p���ɁAHDF
% �t�@�C������ǂݍ��񂾂�A�����o�����߂ɂ́AMATLAB��MATLAB�C���[�W
% �s���J���[�}�b�v�s���u������K�v�����邱�Ƃ��Ӗ����Ă��܂��B
% 
% �p���b�g����ǂݍ��񂾂�A�����o��HDFDFR8���̊֐��́A�͈͂�
% [0,255] ��uint8�^�C�v�̃f�[�^���g���AMATLAB�ł͔͈� [0,1] �̔{���x�l
% ���g���Ă��܂��B���̂��߁AHDF�p���b�g�́AMATLAB�̃J���[�}�b�v�Ƃ���
% ���p�ł���悤�ɔ{���x�ɕϊ����A�X�P�[�����O����K�v������܂��B
% 
% �����o���֐�
% ------------
% �����o���֐��́A���X�^�C���[�W�Z�b�g���쐬���A������V�����t�@�C����
% �ۑ����邩�A�����̃t�@�C���ɕt�������܂��B
%
%   status = hdfdfr8('writeref',filename,ref)
%   �w�肵���Q�Ɣԍ����g���āA���X�^�C���[�W��ۑ����܂��B
%
%   status = hdfdfr8('setpalette',colormap)
%   ������8�r�b�g���X�^�C���[�W�ɑ΂���p���b�g��ݒ肵�܂��B
%
%   status = hdfdfr8('addimage',filename,X,compress)
%   8�r�b�g���X�^�C���[�W���t�@�C���ɕt�������܂��Bcompress �́A'none'�A
%   'rle', 'jpeg', 'imcomp' �̂����ꂩ�ł��B
%
%   status = hdfdfr8('putimage',filename,X,compress)
%   8�r�b�g���X�^�C���[�W�������̃t�@�C���ɏ����o�����A�t�@�C�����쐬����
%   ���Bcompress �́A'none', 'rle', 'jpeg', 'imcomp' �̂����ꂩ�ł��B
%
%   status = hdfdfr8('setcompress',compress_type,...)
%   ���k�̃^�C�v��ݒ肵�܂��Bcompress_type �́A'none', 'rle', 'jpeg', 
%   'imcomp' �̂����ꂩ�ł��Bcompress_type �� 'jpeg' �̏ꍇ�́A2�̒ǉ�
%   �̃p�����[�^��^���Ȃ���΂Ȃ�܂���B�����́Aquality (0��100��
%   �Ԃ̃X�J��)�� force_baseline (0��1�̂����ꂩ)�ł��B���̈��k�̃^�C�v�́A
%   �ǉ��̃p�����[�^�͂���܂���B
%
% �ǂݍ��݊֐�
% ------------
% �ǂݍ��݊֐��́A�C���[�W�̏W���ɑ΂��鎟���ƃp���b�g�̊��蓖�Ă��w�肵�A
% ���ۂ̃C���[�W�f�[�^��ǂݍ��݁A�C�ӂ̃��X�^�C���[�W�Z�b�g�ւ̘A���I��
% ���邢�̓����_���ȃA�N�Z�X��񋟂��܂��B
%
%   [width,height,hasmap,status] = hdfdfr8('getdims',filename)
%   8�r�b�g���X�^�C���[�W�ɑ΂��鎟�����擾���܂��B
%  
%   [X,map,status] = hdfdfr8('getimage',filename)
%   8�r�b�g���X�^�C���[�W�Ƃ��̃p���b�g���擾���܂��B
%
%   status = hdfdfr8('readref',filename,ref)
%   �w�肵���Q�Ɣԍ��������̃��X�^�C���[�W���擾���܂��B
%
%   status = hdfdfr8('restart')
%   �Ō�ɃA�N�Z�X�����t�@�C���Ɋւ�����𖳎����A�ŏ����烊�X�^�[�g
%   ���܂��B
%
%   num_images = hdfdfr8('nimages',filename)
%    �t�@�C�����̃��X�^�C���[�W�����o�͂��܂��B
%
%   ref = hdfdfr8('lastref')
%   �Ō�ɃA�N�Z�X�����v�f�̎Q�Ɣԍ����o�͂��܂��B
%
% �Q�l�FHDF, HDFAN, HDFDF24, HDFH, HDFHD, HDFHE,
%       HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:49 $
