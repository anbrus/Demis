//�������� ���������� � ������������ ��������� �����������

#if !defined(ELEM_INTERFACE_H__INCLUDED_)
#define ELEM_INTERFACE_H__INCLUDED_

#define PT_INPUT        1  //��� �������� - ����
#define PT_OUTPUT       2  //��� �������� - �����
#define ET_INPUTPORT    1  //���� �����
#define ET_OUTPUTPORT   2  //���� ������
#define ET_ARCH         4  //������� �����������
#define ET_CONSTR       8  //������� ������������

#define MAX_CONNECT_POINT 32 //������������ ����� ����� �����������

struct _ElementId {
  CString Name;     //��� ��������
  DWORD   Type;     //��� ��������: ����������� �� ��� �������� ET_xxx
	CString ClsId;
  CBitmap Icon;    //������
};


#endif // !defined(ELEM_INTERFACE_H__INCLUDED_)