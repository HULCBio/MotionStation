% HDFML   MATLAB-HDF�Q�[�g�E�F�C���[�e�B���e�B
% 
% HDFML�́AMATLAB-HDF�̃Q�[�g�E�F�C�֐��Ƌ��ɋ@�\���郆�[�e�B���e�B
% �֐���񋟂��܂��BMATLAB-HDF�̃Q�[�g�E�F�C�֐����g�����߂ɂ́AHDF 
% version 4.1r3��User's Guide��Reference Manual�Ɋ܂܂�Ă������
% ���Ēm���Ă��Ȃ���΂Ȃ�܂���B���̃h�L�������g�́ANational Center 
% for Supercomputing Applications (NCSA)�A<http://hdf.ncsa.uiuc.edu>)
% ���瓾�邱�Ƃ��ł��܂��B
%
% HDFML�̈�ʓI�ȃV���^�b�N�X�́AHDFML(funcstr,param1,param2,...) �ł��B
%
% MATLAB��HDF�̃Q�[�g�E�F�C�֐��́A���Ƃ��΁A���[�U���R�}���h
%
%   clear mex
%
% �����s�����Ƃ��ɁAHDF�I�u�W�F�N�g�ƃt�@�C�����A����ɃN���[�Y����悤
% �ɁAHDF�t�@�C���ƃf�[�^�I�u�W�F�N�g�̎��ʎq�̃��X�g�������Ă��܂��B��
% ���̃��X�g�́A���ʎq���쐬���ꂽ��A���������Ƃ��ɁA�X�V����܂��B
% HDFML���񋟂��邤����2�̊֐��́A�����̎��ʎq�̃��X�g�̑���̂��߂�
% �֐��ł��B
%
%   hdfml('closeall')
%    �I�[�v�����Ă��邷�ׂĂ̓o�^���ꂽHDF�t�@�C���ƁA�f�[�^�I�u�W�F�N�g��
%    ���ʎq���N���[�Y���܂��B
%
%   hdfml('listinfo')
%    �I�[�v�����Ă��邷�ׂĂ̓o�^���ꂽHDF�t�@�C���ƁA�f�[�^�I�u�W�F�N�g��
%    ���ʎq�Ɋւ������\�����܂��B
%
%   tag = hdfml('tagnum',tagname)
%    �^����ꂽ�^�O���ɑΉ�����^�O�ԍ����o�͂��܂��B
%
%   nbytes = hdfml('sizeof',data_type)
%   �w�肵���f�[�^�^�C�v�̃T�C�Y���A�o�C�g�P�ʂŏo�͂��܂��B
%
%   hdfml('defaultchartype',char_type)
%   MATLAB������p�� HDF�f�[�^�^�C�v���`���܂��Bchar_type �p�̐������l
%   �́A'char8'�A�܂��́A'uchar8'�̂����ꂩ�ł��BMATLAB-HDF�Q�[�g�E�F�C
%   �֐����A����������N���A�����܂ŁA�ύX�͕ێ�����܂��BMATLAB������́A
%   �f�t�H���g�ł́Achar8 �Ƀ}�b�s���O����܂��B 
%
% �Q�l�FHDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFSD, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:56 $
