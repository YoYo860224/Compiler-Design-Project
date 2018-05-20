#include "symbol.h"
#include <stdlib.h>
#include <stdio.h>
#include <vector>


variableEntry ve_fn(std::string name, int type){
	variableEntry ve;
	ve.name = name;
	ve.type = type;
	ve.isInit = true;
	ve.isConst = false;
	ve.isArr = false;
	ve.isFn = true;
	ve.arrSize = 1;
	ve.data.intVal = 0;

	return ve;
}


variableEntry ve_basic(std::string name, int type, bool isConst){
	variableEntry ve;
	ve.name = name;
	ve.type = type;
	ve.isInit = true;
	ve.isConst = isConst;
	ve.isArr = false;
	ve.isFn = false;
	ve.arrSize = 1;
	ve.data.intVal = 0;
	
	return ve;
}


variableEntry ve_basic_notInit(std::string name, int type, bool isConst){
	variableEntry ve;
	ve.name = name;
	ve.type = type;
	ve.isInit = false;
	ve.isConst = isConst;
	ve.isArr = false;
	ve.isFn = false;
	ve.arrSize = 1;
	ve.data.intVal = 0;

	return ve;
}

variableEntry ve_arr(std::string name, int type, bool isConst, int arrSize){
	variableEntry ve;
	ve.name = name;
	ve.type = type;
	ve.isInit = true;
	ve.isConst = isConst;
	ve.isArr = true;
	ve.isFn = false;
	ve.arrSize = arrSize;
	ve.data.intVal = 0;

	return ve;
}

symbolTables::symbolTables()
{
	symbolTable st;
	st.scopeName = "GOLOBAL";

	tables.push_back(st);
}

int symbolTables::push_table(std::string name)
{
	symbolTable st;
	st.scopeName = name;

	tables.push_back(st);
}

int symbolTables::update_tableName(std::string name)
{
	tables.back().scopeName = name;
}

int symbolTables::pop_table()
{
	show_topTable();
	tables.pop_back();
}

int symbolTables::show_topTable()
{
	std::cout << "==============================================" << "\n";
	std::cout << "In \'" << tables.back().scopeName << "\' scope" << '\n';
	std::cout << "----------------------------------------------" << "\n";

	for (int i = 0; i < tables.back().variableEntries.size(); i++)
	{
		variableEntry ve = tables.back().variableEntries[i];
		for(int j = 0; j < ve.arrSize; j++)
		{
			if (j != 0)
				std::cout << "--------" << '\t';
			else
				if (ve.isFn)
					std::cout << "Function" << '\t';
				else
					if (ve.isConst)
						std::cout << "Constant" << '\t';
					else
						std::cout << "Variable" << '\t';

			switch (ve.type)
			{
				case T_NONE:
					std::cout << "none" << '\t';

					std::cout << ve.name << '\t';
					std::cout << "?" << '\n';
					break;

				case T_INT:
					std::cout << "int" << '\t';
					if (ve.isArr)
					{
						std::cout << ve.name << '[' << j << ']' << '\t';
						std::cout << ve.data.intArr[j] << '\n';
					}
					else
					{
						std::cout << ve.name << '\t';
						if (ve.isInit)
							std::cout << ve.data.intVal << '\n';
						else
							std::cout << "?" << '\n';
					}
					break;
				case T_FLOAT:
					std::cout << "float" << '\t';
					if (ve.isArr)
					{
						std::cout << ve.name << '[' << j << ']' << '\t';
						if (ve.isInit)
							std::cout << ve.data.floatArr[j] << '\n';
						else
							std::cout << "?" << '\n';
					}
					else
					{
						std::cout << ve.name << '\t';
						if (ve.isInit)
							std::cout << ve.data.floatVal << '\n';
						else
							std::cout << "?" << '\n';
					}
					break;

				case T_BOOL:
					std::cout << "bool" << '\t';
					if (ve.isArr)
					{
						std::cout << ve.name << '[' << j << ']' << '\t';
						if (ve.isInit)
							std::cout << std::boolalpha << ve.data.boolArr[j] << '\n';
						else
							std::cout << "?" << '\n';
					}
					else
					{
						std::cout << ve.name << '\t';
						if (ve.isInit)
							std::cout << std::boolalpha << ve.data.boolVal << '\n';
						else
							std::cout << "?" << '\n';
					}
					break;

				case T_STRING:
					std::cout << "string" << '\t';
					if (ve.isArr)
					{
						std::cout << ve.name << '[' << j << ']' << '\t';
						if (ve.isInit)
							std::cout << ve.data.stringArr[j] << '\n';
						else
							std::cout << "?" << '\n';
					}
					else
					{
						std::cout << ve.name << '\t';
						if (ve.isInit)
							std::cout << ve.data.stringVal << '\n';
						else
							std::cout << "?" << '\n';
					}
					break;

				default:
					break;
			}
		}
	}
	std::cout << "==============================================" << "\n";
}

int symbolTables::addVariable(variableEntry var)
{
	if (lookupForNowScope(var.name).type == T_404)
		tables.back().variableEntries.push_back(var);
	else
		return 0;

	return 1;
}

int symbolTables::editVariable(variableEntry var)
{
	for (int i = tables.size() - 1; i >= 0; i--)
	{
		for (int j = 0; j < tables[i].variableEntries.size(); j++)
		{
			variableEntry ve = tables[i].variableEntries[j];
			if (ve.name == var.name)
			{
				if (!ve.isConst)
					tables[i].variableEntries[j] = var;
			}
		}
	}
	return 0;
}

int symbolTables::forPreloadFN(int type)
{
	tables[tables.size()-2].variableEntries.back().type = type;
}

variableEntry symbolTables::lookup(std::string name)
{
	for (int i = tables.size() - 1; i >= 0; i--)
	{
		for (int j = 0; j < tables[i].variableEntries.size(); j++)
		{
			variableEntry ve = tables[i].variableEntries[j];
			if (ve.name == name)
				return ve;
		}
	}
	variableEntry notFound;
	notFound.type = T_404;
	return notFound;
}


variableEntry symbolTables::lookupForNowScope(std::string name)
{
	for (int j = 0; j < tables.back().variableEntries.size(); j++)
	{
		variableEntry ve = tables.back().variableEntries[j];
		if (ve.name == name)
			return ve;
	}

	variableEntry notFound;
	notFound.type = T_404;
	return notFound;
}
