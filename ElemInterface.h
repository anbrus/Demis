//Описание интерфейса с библиотеками элементов архитектуры

#if !defined(ELEM_INTERFACE_H__INCLUDED_)
#define ELEM_INTERFACE_H__INCLUDED_

#define PT_INPUT        1  //Тип контакта - ввод
#define PT_OUTPUT       2  //Тип контакта - вывод
#define ET_INPUTPORT    1  //Порт ввода
#define ET_OUTPUTPORT   2  //Порт вывода
#define ET_ARCH         4  //Элемент архитектуры
#define ET_CONSTR       8  //Элемент конструктива

#define MAX_CONNECT_POINT 32 //Максимальное число точек подключения

struct _ElementId {
  CString Name;     //Имя элемента
  DWORD   Type;     //Тип элемента: объединение по ИЛИ констант ET_xxx
	CString ClsId;
  CBitmap Icon;    //Иконка
};


#endif // !defined(ELEM_INTERFACE_H__INCLUDED_)