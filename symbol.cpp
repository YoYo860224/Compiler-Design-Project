#include "symbol.h"
#include <stdlib.h>
#include <stdio.h>
#include <vector>

symbolTables::symbolTables(/* args */)
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

int symbolTables::pop_table()
{
	show();
	tables.pop_back();
}

int symbolTables::addVariable(variableEntry var)
{
	tables.back().variableEntries.push_back(var);
}

int symbolTables::editVariable(variableEntry var)
{
	for (int i = tables.size(); i >= 0; i--)
	{
		for (int j = 0; j < tables.size(); j++)
		{
			variableEntry ve = tables[j].variableEntries[i];
			if (ve.name == var.name)
			{
				if (!ve.isConst)
					tables[j].variableEntries[i] = var;
			}
		}
	}
	return 0;
}

variableEntry symbolTables::lookup(std::string name)
{    
	for (int i = tables.size(); i >= 0; i--)
	{
		for (int j = 0; j < tables.size(); j++)
		{
			variableEntry ve = tables[j].variableEntries[i];
			if (ve.name == name)
				return ve;
		}
	}
	variableEntry none;
	none.type = T_NONE;
	return none;
}

void symbolTables::show()
{
	std::cout << "==============================================" << "\n";
	std::cout << "In \'" << tables.back().scopeName << "\' scope" << '\n';
	std::cout << "----------------------------------------------" << "\n";

	for (int i = 0; i < tables.size(); i++)
	{		
		variableEntry ve = tables.back().variableEntries[i];
		for(int j = 0; j < ve.arrSize; j++)
		{	
			if (j != 0)
				std::cout << "--------" << '\t';
			if (ve.isConst)
				std::cout << "Constant" << '\t';
			else
				std::cout << "Variable" << '\t';

			switch (ve.type)
			{		
				case T_INT:
					std::cout << "int" << '\t';
					if (ve.isArr)
					{
						std::cout << ve.name << '[' << j << ']' << '\t';
						std::cout << ve.data.intArr[j] << '\t';
					}
					else
					{
						std::cout << ve.name << '\t';
						std::cout << ve.data.intVal << '\t';
					}
					break;

				case T_FLOAT:
					std::cout << "float" << '\t';
					if (ve.isArr)
					{
						std::cout << ve.name << '[' << j << ']' << '\t';
						std::cout << ve.data.floatArr[j] << '\t';
					}
					else
					{
						std::cout << ve.name << '\t';
						std::cout << ve.data.floatVal << '\t';
					}
					break;

				case T_BOOL:
					std::cout << "bool" << '\t';
					if (ve.isArr)
					{
						std::cout << ve.name << '[' << j << ']' << '\t';
						std::cout << ve.data.boolArr[j] << '\t';
					}
					else
					{
						std::cout << ve.name << '\t';
						std::cout << ve.data.boolVal << '\t';
					}
					break;

				case T_STRING:
					std::cout << "string" << '\t';
					if (ve.isArr)
					{
						std::cout << ve.name << '[' << j << ']' << '\t';
						std::cout << ve.data.stringArr[j] << '\t';
					}
					else
					{
						std::cout << ve.name << '\t';
						std::cout << ve.data.stringVal << '\t';
					}
					break;

				default:
					break;
			}
		}		
	}
	std::cout << "==============================================" << "\n";
}