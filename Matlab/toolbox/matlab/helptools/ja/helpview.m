% HELPVIEW   HTML�t�@�C���̕\���A�܂��̓v���b�g�t�H�[���ˑ��̃w���v
% �r���[���̕\��
% 
% �\��:
%
%  helpview (coll_path)
%  helpview (coll_path�Awin_type)
%  helpview (topic_path)
%  helpview (topic_path�Awin_type)
%  helpview (topic_path, win_type, parent)
%  helpview (map_path�Atopic_id)
%  helpview (map_path�Atopic_id�Awin_type)
%  helpview (map_path, topic_id, win_type, parent)
%
% ����:
%
% coll_path
% HTML�t�@�C���̏W���̃p�X�B�p�X�̍Ō�̖��O�́A�t�@�C���̏W���̖��O�ł��B
%
% topic_path
% HTML�t�@�C���̃p�X�B�p�X�́A.htm(l)��htm(l)��HTML�̃A���J�[�̎Q�Ƃ�
% �I�����Ȃ���΂Ȃ�܂���B���Ƃ��΁A
%
%     /v5/help/helpview.html#topicpath
%     d:/v5/help/helpview.html#topicpath 
%
% �ƂȂ�܂��B
%
% map_path
% �g�s�b�N��ids���g�s�b�N�t�@�C���̃p�X�Ɏˉe����}�b�v�t�@�C��(���L�Q��)
% �̃p�X�B�p�X�́A�g���q.map�ŏI�����Ȃ���΂Ȃ�܂���B���Ƃ��΁A����
% �悤�ɂȂ�܂��B
%
%    d:/v5/help/ml_graph.map
%
% topic_id
% �g�s�b�N�����ʂ���C�ӂ̕�����BHELPVIEW�́Atopic_id���g�s�b�N�̋L�q��
% ��HTML�t�@�C���̃p�X�Ɏˉe���邽�߂ɁA�p�X�ɂ���Ďw�肳���}�b�v�t�@
% �C�����g�p���܂��B
%
% win_type
% �w���v���e��\������E�B���h�E�̃^�C�v�B"CSHelpWindow"��ݒ肷��ƁA
% �R���e�L�X�g�Z���V�e�B�u�ȃw���v�r���[�����g�p���邱�ƂɂȂ�܂��B����
% �ꍇ�́A���C����"�w���v"�E�B���h�E���g���܂��B
%
% parent
% figure �E�B���h�E�ɑ΂���n���h���B�w���v�_�C�A���O�� parent ������
% ���邽�߂ɁA"CSHelpWindow" win_type �ɂ��g�p����܂��B���̈����́A
% win_type �� CSHelpWindow �łȂ��ꍇ�A��������܂��B
%
% TOPIC MAP FILE
%
% �}�b�v�t�@�C���́A��{�I�ɂ�2��ŕ\������ ascii �e�L�X�g�t�@�C���ł��B
% �e�X�̍s�́A���̌`���ł��B
%
% TOPIC_ID  PATHNAME
%
% TOPIC_ID�́AHTML�t�@�C���Ɋ܂܂��I�����C���w���v��"chunk"�����ʂ���
% �C�ӂ̕�����ł��B�T���āA�e�N�j�J�����C�^��J���҂́A�����̎��ʎq��
% �������̂ɓ��ӂ��Ă��܂��B�J���҂́Ahelpview �̌Ăяo���ɁA�������g
% ���܂��B  
%
% PATHNAME�́A�}�b�v�t�@�C�����܂ރf�B���N�g���ɑ΂���coll_path�܂���
% topic_path�ł��B
%  
% ���Ƃ��΁A���̃}�b�v�t�@�C��
%
% ml_graph.map
%  COLORPICKDLG  ml_graph/ch02aa31.html
%  PRINTDLG      ml_graph/ch02aa35.html
%  LINESTYLEDLG  ml_graph/ch02aa31.html#ModLines
%
% ���f�B���N�g��DOCROOT\techdoc�ɂ���Ɖ��肵�܂��B�����ŁADOCROOT��
% MATLAB�w���v�V�X�e���̃��[�g�f�B���N�g���ł��B���̂Ƃ��A���̌Ăяo��
%
%  helpview([DOCROOT '/techdoc/ml_graph.map']�A'PRINTDLG');
% 
%  �́A���̂��̂Ɠ����ł��B
%
%  helpview([DOCROOT '/techdoc/ml_graph/ch02aa35.html']);
% 

