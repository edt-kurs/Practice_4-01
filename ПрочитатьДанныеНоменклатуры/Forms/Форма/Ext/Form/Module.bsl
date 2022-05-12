﻿
#Область ОбработчикиСобытийФормы

#КонецОбласти


#Область ОбработчикиСобытийЭлементов

&НаКлиенте
Процедура ФайлДанныхНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	ДиалогВыбораФайла =	Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	ДиалогВыбораФайла.Фильтр = "Файл данных (*.xlsx)|*.xlsx";
	ДиалогВыбораФайла.Расширение = "xlsx";
	
	ДиалогВыбораФайла.Заголовок = "Выберите файл";
	ДиалогВыбораФайла.ПредварительныйПросмотр =	Ложь;
	ДиалогВыбораФайла.ИндексФильтра = 0;
	ДиалогВыбораФайла.ПолноеИмяФайла = ФайлДанных;
	ДиалогВыбораФайла.ПроверятьСуществованиеФайла =	Истина;
	
	Если ДиалогВыбораФайла.Выбрать() Тогда
		ФайлДанных = ДиалогВыбораФайла.ПолноеИмяФайла;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяЛистаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Попытка
		Состояние("Внимание! ... идёт загрузка данных!");
		Excel = Новый COMОбъект("Excel.Application");
		WB = Excel.Workbooks.Open(ФайлДанных);
	Исключение
		Предупреждение("Внимание! Файл не открыт." + Символы.ПС + "Попробуйте открыть и пересохранить данный файл программой Эксель.");
		Возврат;
	КонецПопытки;
	
	Сп = Новый СписокЗначений;
	
	Для Ш = 0 по WB.Sheets.Count Цикл
		Сп.Добавить(WB.Sheets(Ш).Name);
	КонецЦикла;
	
	WB.Close(0);
	
	Рез = Сп.ВыбратьЭлемент("Выберите лист документа Excel.");
	
	Если Рез = Неопределено Тогда
		ИмяЛиста = "";
	Иначе
		ИмяЛиста = Рез.Значение;
	КонецЕсли;	
	
КонецПроцедуры

&НаКлиенте
Процедура ДанныеНоменклатураПриИзменении(Элемент)
	
	ТекущиеДанные = Элементы.Данные.ТекущиеДанные;
	ТекущиеДанные.Код = КодНоменклатуры(ТекущиеДанные.Номенклатура);
	
КонецПроцедуры

#КонецОбласти


#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ПрочитатьФайл(Команда)

	Если СокрЛП(ФайлДанных) = "" Тогда
		Сообщить("Выберите файл выгрузки.", СтатусСообщения.Важное);
		Возврат;
	КонецЕсли;
	
	Если СокрЛП(ИмяЛиста) = "" Тогда
		Сообщить("Выберите имя листа Excel из файла выгрузки.", СтатусСообщения.Важное);
		Возврат;
	КонецЕсли;
	
	WB = 0;
	Попытка
		Состояние(" Внимание! ... идёт загрузка данных!");
		Excel = Новый COMОбъект("Excel.Applications");
		WB = Excel.Workbooks.Open(ФайлДанных);
		WS = WB.Worksheets(СокрЛП(ИмяЛиста));	//указываем номер листа - 1
	Исключение
		Если WB <> 0 Тогда
			WB.Close(0);
		КонецЕсли;
		Предупреждение("Внимание! Файл не открыт." + Символы.ПС + "Попробуйте открыть и пересохранить данный файл программой Excel.");
		Возврат;
	КонецПопытки;
		
	Данные.Очистить();
	НомСтр = 2;
	
	Попытка
		Пока Истина Цикл
			Состояние("Читаю строку " + НомСтр);
				
			КодТовара = WS.Cells(НомСтр, 1).Value;
			Если (КодТовара = Неопределено) Или (СокрЛП(КодТовара) = "") Или (КодТовара = 0) Тогда
				Прервать;
			КонецЕсли;
				
			Если ТипЗнч(КодТовара) = Тип("Число") Тогда
				КодТовара = Формат(КодТовара, "ЧГ=0");
			КонецЕсли;
					
			Номенклатура = НоменклатураНайтиПоКоду(КодТовара);
			Если Не ЗначениеЗаполнено(Номенклатура) Тогда
				Сообщить("Не найдена номенклатура с кодом (" + КодТовара + ") в строке (" + НомСтр + ").");
				НомСтр = НомСтр + 1;
				Продолжить;
			КонецЕсли;
			
			Если СокрЛП(КодТовара) = "00-00023924" Тогда
				А = 0;
			КонецЕсли;
			
			Штрихкод  = WS.Cells(НомСтр, 2).Text;
			ДлинаВмм  = WS.Cells(НомСтр, 3).Value;
			ШиринаВмм = WS.Cells(НомСтр, 4).Value;
			ВысотаВмм = WS.Cells(НомСтр, 5).Value;
			
			Стр = Данные.Добавить();
			Стр.НомерСтроки  = НомСтр - 1;
			Стр.Код 		 = КодТовара;
			Стр.Номенклатура = Номенклатура;
			Стр.Штрихкод     = СокрЛП(Штрихкод);
			Стр.ДлинаВмм	 = ?(ЗначениеЗаполнено(ДлинаВмм),  Число(ДлинаВмм), 0);
			Стр.ШиринаВмм    = ?(ЗначениеЗаполнено(ШиринаВмм), Число(ШиринаВмм), 0);
			Стр.ВысотаВмм    = ?(ЗначениеЗаполнено(ВысотаВмм), Число(ВысотаВмм), 0);
			
			НомСтр = НомСтр + 1;
		КонецЦикла;
	Исключение
		Предупреждение("Ошибка разбора файла! Строка " + НомСтр);
		WB.Close(0);
		Возврат;
	КонецПопытки;
		
	Сообщить("Данные из файла " + ФайлДанных + " загружены.");

	WB.Close(0);
	
КонецПроцедуры

#КонецОбласти


#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция НоменклатураНайтиПоКоду(КодТовара)
	
	Возврат Справочники.Номенклатура.НайтиПоКоду(КодТовара);
	
КонецФункции

&НаСервереБезКонтекста
Функция КодНоменклатуры(Номенклатура)
	
	Возврат Номенклатура.Код;
	
КонецФункции

#КонецОбласти
