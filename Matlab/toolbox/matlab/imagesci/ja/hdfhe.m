% HDFHE   HDF HE�C���^�t�F�[�X��MATLAB�Q�[�g�E�F�C
% 
% HDFHE�́AHDF HE�C���^�t�F�[�X�ւ̃Q�[�g�E�F�C�ł��B���̊֐����g������
% �ɂ́AHDF version 4.1r3��User's Guide��Reference Manual�Ɋ܂܂�Ă���A
% Vdata�C���^�t�F�[�X�ɂ��Ă̏���m���Ă��Ȃ���΂Ȃ�܂���B���̃h
% �L�������g�́ANational Center for Supercomputing Applications (NCSA�A
% <http://hdf.ncsa.uiuc.edu>)���瓾�邱�Ƃ��ł��܂��B
%
% HDFHE�ɑ΂����ʓI�ȃV���^�b�N�X�́AHDFHE(funcstr,param1,param2,...)
% �ł��BHDF���C�u��������V�֐��ƁAfuncstr �ɑ΂���L���Ȓl�́A1��1�őΉ�
% ���܂��B
%
% �V���^�b�N�X�̎g����
% --------------------
% �X�e�[�^�X�A�܂��́A���ʎq�̏o�͂�-1�̂Ƃ��A���삪���s�������Ƃ�������
% ���B
%
%   hdfhe('clear')
%   �񍐂��ꂽ�G���[�Ɋւ��邷�ׂĂ̏����A�G���[�X�^�b�N����������܂��B
% 
%   hdfhe('print',level)
%   �G���[�X�^�b�N���̏���\�����܂��Blevel ��0�̏ꍇ�́A�G���[�X�^�b�N�S��
%   ���\������܂��B
%
%   error_text = hdfhe('string',error_code)
%   �w�肵���G���[�R�[�h�ɑΉ�����G���[���b�Z�[�W���o�͂��܂��B
%
%   error_code = hdfhe('value',stack_offset)
%   �G���[�X�^�b�N�̎w�肵�����x������A�G���[�R�[�h���o�͂��܂��B
%   stack_offset��1�̂Ƃ��A�ŐV�̃G���[�R�[�h���擾���܂��B
%
% HDF���C�u�����֐� HEpush �� HEreport �́A���݂͂��̃Q�[�g�E�F�C�ł̓T
% �|�[�g����Ă��܂���B
%
% �Q�l�FHDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, 
%       HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:53 $
