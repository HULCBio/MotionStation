% GETPREF �D�揇�ʂ̎擾
%
% GETPREF('GROUP','PREF') �́AGROUP �� PREF �Ŏw�肵���D�揇�ʂ̒l��
% �o�͂��܂��B���݂��Ȃ��D�揇�ʂ𓾂悤�Ƃ���ƁA�G���[���ł܂��B
%
% GROUP �́A�D�揇�ʂɂ��Ċ֘A������̂��܂Ƃ߂ă��x���t���������̂�
% ���B������I������ɂ́AMATLAB�̐������ϐ����L�@�ŁA���Ƌ�ʂ̕t��
% ���O�A���Ƃ��΁A'MathWorks_GUIDE_ApplicationPrefs'���g���Ă��������B
%
% PREF �́A�Ώۂ̃O���[�v�̒��̌X�̗D�揇�ʂ����ʂ��܂��B�����ŁAPREF 
% �͐������ϐ����łȂ���΂Ȃ�܂���B
%
% GETPREF('GROUP','PREF',DEFAULT) �́AGROUP �� PREF �Ŏw�肵���D�揇��
% �����݂���ꍇ�ɃJ�����g�̒l���o�͂��܂��B���̑��̏ꍇ�́A�w�肵��
% �f�t�H���g�l�����D�揇�ʂ��쐬���A���̒l��߂��܂��B
%
% GETPREF('GROUP',{'PREF1','PREF2',...'PREFn'}) �́AGROUP �ƗD�揇�ʂ�
% �Z���z��Ŏw�肵���D�揇�ʂ̒l���܂ރZ���z���߂��܂��B�߂�l�́A
% ���̓Z���z��Ɠ����傫���ł��B�D�揇�ʂ̂���������݂��Ȃ��ꍇ�A�G���[
% �ɂȂ�܂��B
%
% GETPREF('GROUP',{'PREF1',...'PREFn'},{DEFAULT1,...DEFAULTn}) �́AGROUP 
% �Ŏw�肵���D�揇�ʂ̃J�����g�l�����Z���z��ƗD�揇�ʂ̖��O�̃Z���z��
% ���o�͂��܂��B���݂��Ă��Ȃ��D�揇�ʂ́A�w�肵���f�t�H���g�l�Ƌ��ɍ쐬
% ����A�o�͂���܂��B
%
% GETPREF('GROUP') �́AGROUP �̒��̂��ׂĂ̗D�揇�ʂ̖��O�ƒl���\����
% �Ƃ��ďo�͂��܂��B
%
% GETPREF �́A���ׂẴO���[�v�ƗD�揇�ʂ��\���̂Ƃ��ďo�͂��܂��B
%
% �D�揇�ʒl�́AMATLAB�Z�b�V�����ԂŁA�Œ�l�Ƃ��Ď�舵���܂��B
% �������X�g�A����ꏊ�́A�V�X�e���Ɉˑ����܂��B
%
% ���F
%      addpref('mytoolbox','version',1.0)
%      getpref('mytoolbox','version')
%
% ���F
%      getpref('mytoolbox','version',1.0);
% 
% �Q�l�FSETPREF, ADDPREF, RMPREF, ISPREF, UIGETPREF, UISETPREF


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $
