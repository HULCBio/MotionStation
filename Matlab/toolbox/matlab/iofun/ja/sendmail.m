% SENDMAIL ���[�����b�Z�[�W�̑��M
% SENDMAIL(TO,SUBJECT,MESSAGE,ATTACHMENTS) �́A�d�q���[���𑗐M���܂��BTO �́A
% 1�̃A�h���X���w�肷�镶����A�܂��́A�A�h���X�̃Z���z��̂����ꂩ�ł��B
% SUBJECT �́A������ł��BMESSAGE �́A������A�܂��́A�Z���z��̂����ꂩ�ł��B
% ������ł���ꍇ�A�e�L�X�g�́A75 �����Ŏ����I�Ƀ��b�v���܂��B�Z���z���
% ����ꍇ�A���b�v���܂��񂪊e�Z���͐V�������C�����n�߂܂��B������̏ꍇ���A
% char(10) ���g�p���ĐV�������C�����w�肵�܂��BATTACHMENTS �́A���b�Z�[�W
% �ƂƂ��ɑ���t�@�C���̃��X�g�̕�����̃Z���z��ł��BTO �� SUBJECT �̂ݕK�v
% �ł��B
%
% SENDMAIL �́A2�̃v���t�@�����X�A���[���T�[�o "Internet:SMTP_Server", 
% ����сA�d�q���[���A�h���X "Internet:E_mail" �Ɉˑ����܂��BSENDMAIL ��
% �g�p����O�ɁASETPREF �ɂ�肱����ݒ肵�Ă��������B���M���郁�[��
% �T�[�o���w�肷��ɂ́A ���̓d�q���[���A�v���P�[�V�����̃v���t�@�����X��
% ���ׂ邩�A�Ǘ��҂ɑ��k���Ă��������B�T�[�o�̖��O��T�����Ƃ��ł��Ȃ�
% �ꍇ�A'mail' �Ɛݒ肷��Ɠ��삷��\��������܂��B�����̃v���t�@�����X
% ��ݒ肵�Ȃ��ꍇ�ASENDMAIL ���A���ϐ��� Windows ���W�X�g����ǂނ��Ƃ�
% �����I�Ɍ��肵�悤�Ƃ��܂��B
%
% ���:
%     setpref('Internet','SMTP_Server','mail.example.com');
%     setpref('Internet','E_mail','matt@example.com');
%     sendmail('user@example.com','Calculation complete.')
%     sendmail({'matt@example.com','peter@example.com'},'You''re cool!', ...
%       'See the attached files for more info.',{'attach1.m','d:\attach2.doc'});
%     sendmail('user@example.com','Adding additional breaks',['one' 10 'two']);
%     sendmail('user@example.com','Specifying exact lines',{'one','two'});

% SMTP �v���g�R���𒼐ڎg�p���Ă��������B�^����ꂦ�����[���T�[�o�� SMTP ��
% �ڑ����Ęb���܂��Bmultipart/mixed ���b�Z�[�W�𑗐M���邽�߂ɂ́AMIME 
% �G���R�[�f�B���O���g�p���Ă��������B
%
% RFC 821 �́ASMTP ��ԃR�[�h�����X�g���܂��B���̃h�L�������g���C���^�[
% �l�b�g�ɑ�������܂��B���Ƃ��āA
% http://www.landfield.com/rfcs/rfc821.html ���Q�Ƃ��Ă��������B

% Peter Webb, Aug. 2000
% Matthew J. Simoneau, Nov. 2001, Aug 2003
% Copyright 1984-2003 The MathWorks, Inc.
