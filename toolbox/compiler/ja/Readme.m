% �����[�X�m�[�g, MATLAB Compiler
% 
% V2.1 Compiler�p�I�v�V�����͑O�o�[�W�����Ƃ͈قȂ�A���o�[�W������
% �I�v�V�����Z�b�g�Ɋւ���w���v�́A"mcc -?" �𗘗p���ĉ������B
% �������A���̎��̕\���͉p��o�[�W�����ƂȂ�܂��B���{��w���v��
% ����ꍇ�́AMATLAB�v�����v�g���"help mcc" �𗘗p���ĉ������B
% �ύX���ꂽ�I�v�V�����Ɋւ���ڍׂ́A"�R�}���h�s�̍���"�̃Z�N�V����
% ���Q�Ɗ肢�܂��B 
% 
% Compiler 2.1 �V�K�@�\
% 
% - Visual Studio��MATLAB�A�h�C�� - MATLAB Compiler 2.1��Visual C/C++
%   5�����6�ɓ������܂��Bmbuild -setup��mex -setup�����s����ƁA����
%   �I��Microsoft Visual Studio�Ƀv���W�F�N�g�E�B�U�[�h��ǉ�����̂ŁA
%   M-�t�@�C���̃R���p�C������s����Visual Studio���𗘗p�ł��܂��B
%   �܂�Matrix Viewer������Visual Studio�̃c�[���o�[������܂��B
%   Visual Studio���J���A���j���[����"�c�[��->�J�X�^�}�C�Y->�A�h�C��"
%   ��I�����܂��B���̃_�C�A���O�{�b�N�X�ɁAMATLAB�A�h�C���𗘗p�\��
%   ����悤�ɁA�`�F�b�N�{�b�N�X��I�����܂��B���̏��ɂ��ẮA
%   �h�L�������g����MATLAB�A�h�C���Ɋւ���Z�N�V�������Q�Ƃ��ĉ������B
%
% - �œK�� - ����ނ̍œK����Compiler 2.1�œK�p����܂����B�e�œK���N��
%   �X��-O <class>:on ���邢��-O <class>:off �𗘗p���ČX�ɐݒ�ł���
%   ���B�܂��œK���S�Ă�L���ɂ���-O all ���w�肷�鎖���ł��܂��B
%
%   * fold_scalar_mxarrays - �X�J���]�����ꂽ�z��萔���܂Ƃ߂�B
%   * fold_non_scalar_mxarrays - ��X�J���]�����ꂽ�z��萔���܂Ƃ߂�B
%   * optimize_integer_for_loops - �����Ŏn�܂葝������for���[�v���œK��
%                                  ����B
%
% - Compiler �œK���@�\�ɉ����A���\�����Ȃ���P����ɂ́AC/C++ Math
%   Library �ɒ��ڂ��܂��B��X�́A�����̃��C�u�����֐��̃X�J�������o�[
%   �W�����������A�S�Ẵ��C�u�����A�v���P�[�V�����̎x�z�I�Ȑ��\�����P
%   ���܂����B
%
% - MEX-�t�@�C�� - MEX-�t�@�C���́A�X�^���h�A�������ŃT�|�[�g�����l
%   �ɂȂ�܂����B-h�̎w��́A�����I�ɎQ�Ƃ����MEX-�t�@�C�������R���p�C
%   �����܂��B�R�}���h�s�ł�MEX-�t�@�C���̎w��̓T�|�[�g����AM-�t�@�C��
%   �̃R���p�C�����@���l�ɋ@�\���܂��B
%   1�A����������܂��B�X�^���h�A�����R�[�h����Compiler����������MEX-
%   �t�@�C�������s���鎖�͂ł��܂���B����͏d�v�Ȑ����ł͂���܂���B
%   M-�t�@�C���͒��ڃC���N���[�h����ACompiler�ɂ���đI�΂�邩��ł��B
%   ���̋@�\�Ɋւ���ڍׂɂ��ẮA�h�L�������g���Q�Ƃ��ĉ������B
%
% - MLIB-�t�@�C�� - (�Ⴆ�΁AToolbox��) �t�@�C���Z�b�g�����C�u������
%   �R���p�C������ƁACompiler�́A���C�u�����ɓK���\�ȗl�X��M�t�@���N
%   �V������M�C���^�t�F�[�X�����P�Ƃ̃t�@�C�����쐬���܂��B���̂��߂�
%   �̃t�@�C���́AM-�t�@�C�����ăR���p�C�������Ƀ��C�u��������M-�t�@�C��
%   �ɃR�[�������鑼�̃t�@���N�V�������R���p�C�����܂��B
%   ���̂��Ƃ́AToolbox���狤�L���C�u�������쐬���A����Toolbox�ɃR�[����
%   ��M-�t�@�C�����R���p�C�����邱�Ƃ��\�ɂ��܂��B����烉�C�u�����L�q
%   �t�@�C���̊g���q�́A.MLIB�ł��BMLIB�t�@�C���Ɋւ�����́A�h�L��
%   �����g���Q�Ƃ��ĉ������B
%
% - MATLAB 5 �����f�[�^�`�� (int8,16,32 ����� uint8,16,32) �́A�T�|�[�g
%   ����܂����B
%
% - EVAL �́A���[�N�X�y�[�X�ϐ����܂܂Ȃ�������ɑ΂��āA�T�|�[�g�����
%   �����B
%
% - INPUT �́A���͕�����ɂ���EVAL �Ɠ��������ŁA�T�|�[�g����܂����B
%
% - �ϐ������܂܂Ȃ�LOAD/SAVE �́A���ɃT�|�[�g����܂����B
%
% - PAUSE ���A�T�|�[�g����܂����B
%
% - CONTINUE ���A�T�|�[�g����܂����B
%
% - FUNCTION �n���h�����A�T�|�[�g����܂����B
%
% - ���̃����[�X���_�ŁACompiler 1.2 �͗��p�ł����AMATLAB�̓����f�[�^
%   �\���̐i���ɂ��T�|�[�g����܂���B
%
%
% Compiler 2.1 ��ʏ��
%
% Compiler �́ADOS/Unix�V�F������̎��s�ł��A���p�ł��܂��B
%
% Compiler �́A�ȉ��̌���@�\���T�|�[�g���܂��B
%
%     * �������z��
%     * �\����
%     * �Z���z��
%     * �X�p�[�X�z��
%     * varargin/varargout
%     * SWITCH/CASE
%     * TRY/CATCH
%     * EVALIN (MEX ���[�h�Ɍ���)
%     * PERSISTENT
%
%  Compiler �̂��̃o�[�W�����ŃT�|�[�g����Ȃ��@�\�́A�ȉ��ł��B
%
%     * ���[�U��`�N���X (MATLAB �I�u�W�F�N�g)
%     * MATLAB Java �C���^�t�F�[�X�ւ̃R�[��
%
% MATLAB C/C++ Math Library�Ɋւ���ŐV���́A�ȉ��̊e�X�̃t�@�C�����Q
% �Ɗ肢�܂��B
% MATLABROOT/extern/examples/cmath/release.txt 
% MATLABROOT/extern/examples/cppmath/release.txt
%
% 
% Windows 95/98/NT �J�X�^�}�ɑ΂��钍��: ����Compiler�����[�X�ł́A�ȉ�
% �̃v���b�g�t�H�[���̃R���p�C���x���_�[�␻�i�����[�X�̃��X�g���A�T�|�[�g
% ����܂��B
%
%       MSVC C/C++ 4.2, 5.0, 6.0(*)
%       Borland C++ 5.0, 5.02
%       Borland C++Builder 3, 4, 5
%       Borland C++ 5.5 (�t���[�̃R�}���h���C���c�[��)
%       LCC (C �݂̂̃R���p�C���AMATLAB�Ƀo���h��)
%
% (*) MSVC 6.0���C���X�g�[�����鎞�A���̃R���p�C���̃C���X�g�[�����ύX
% ����K�v������ꍇ�́A(����̃C���X�g�[���_�C�A���O��) Common�f�B���N�g��
% �̈ʒu��ύX���Ȃ���΂Ȃ�܂���B�����A�f�t�H���g�ݒ�̃f�B���N�g��
% ����VC98�f�B���N�g���̈ʒu��ύX����ƁAMEX��MBUILD�X�N���v�g�͐�����
% �@�\���Ȃ��ł��傤�B
%
% MATLAB Compiler���p���ɖ�肪���������ꍇ�́A���̖��𒲍����A�C��
% ���邽�߂Ƀo�O���|�[�g���L�����ĉ������B
% (�ڍׂ́Ahelp COMPILER_BUG_REPORT �ƃ^�C�v���ĉ������B)
%
% ��O������Compiler����C++�R�[�h
%
% C++�𗘗p����ꍇ�́AC++����ł̗�O�����̋@�\�����p�ł��܂��B�T�|�[�g
% �����R���p�C���̒��ɂ́AC++�̗�O�����������ɃT�|�[�g���Ȃ����̂���
% ��A���̌��ʁA���ɋ�����v���b�g�t�H�[���ł͗�O�����ɑ΂���T�|�[�g��
% �͐���������܂��B
%
%       GNU C++ 2.7.2             - C++��O�������T�|�[�g���܂���B
%       Borland C++(all versions) - try/catch�u���b�N����goto���̃T�|�[
%                                   �g�ɐ���������܂��BMATLAB Compiler
%                                   �ł͕��G��"if"�������ɑ΂���goto����
%                                   ��������ꍇ������܂��B���̂悤�Ȑ�
%                                   ���R�[�h�́ABorland C++�ł̓R���p�C
%                                   ������܂���B���ʂƂ��āAif��������
%                                   �������邱�Ƃ��v������܂��B
%
% ����: -A debugline �̃X�C�b�`�́Atry/catch���𗘗p���Ď��{����A���̃X
%       �C�b�`�̗��p���������R�����L��C++�������@�ŁA����������܂��B
%
% �R�}���h���C���̍���
%
% �V�K�X�C�b�`:
%   O <optimization> �œK���B3�̔\�͂�����܂��B:
%
%    <optimization class>:[on|off] - �N���X��on��������off��Ԃ��܂��B
%    ��:  -O fold_scalar_mxarrays:on
%
%    list - �L���ȍœK���N���X�����X�g���܂��B
%
%    <optimization level> - �œK����on��off�̉��ꂩ�Ɍ��肷�邽�߂ɁA
%    opt_bundle_<level> �Ƃ����o���h�����ꂽ�t�@�C���𗘗p���܂��B
%    �Ⴆ�΁A"-O all"��opt_bundle_all�Ƃ����o���h���t�@�C����T���A����
%    �̃X�C�b�`�𗘗p���܂��B���݂̍œK�����x����"all"��"none"�ł��B
%
% �V�K�t�@�C���^�C�v
%
%    ���̃����[�X�̑O�́ACompiler��MBUILD��Compiler�̃R�}���h���C����
%    �w�肳�ꂽMLIB-�t�@�C����MEX-�t�@�C����n���܂����B���̃����[�X�ł�
%    �����t�@�C����Compiler�ɂ���ď�������܂��BCompiler��MEX-�t�@�C
%    ����MLIB-�t�@�C���Ɋւ�����́A��L�Z�N�V�������Q�Ƃ��ĉ������B
%
% �����̃X�C�b�`
%
%    -V1.2 �X�C�b�`��V1.2 Compiler�ŔF�߂��Ă�������A���邢�͑S�Ă�
%    �X�C�b�`�Ƌ��ɁA�����T�|�[�g����܂���B


% $Revision: 1.9.4.1 $  $Date: 2003/06/25 14:31:07 $
% Copyright 1984-2002 The MathWorks, Inc.
