#ifndef SYMBOL_H
#define SYMBOL_H

#include <string>
#include <vector>
#include <iostream>
#include <stdlib.h>
#include <stdio.h>

enum TYPE
{
	T_NONE,
	T_INT,
	T_FLOAT,
	T_BOOL,
	T_STRING,
	T_404
};

typedef union {
	int intVal;
	float floatVal;
	bool boolVal;
	char* stringVal;

	int* intArr;
	float* floatArr;
	bool* boolArr;
	char** stringArr;
} variableData;

typedef struct variableEntry {
	std::string name;
	int type;

	bool isConst;		// if constant, use value in data.
	union {
		variableData data;
	};

	bool isGlobal;		// if not global variable, use stack index.
	int stackIndex;

	bool isFn;			// if function, need argument.
	int argSize;
	int argType[15];

	bool isInit;		// none of use for project3.

	bool isArr;			// none of use for project3.
	int arrSize;
} variableEntry;

// Some make variableEntry methon.
variableEntry ve_fn(std::string name, int type);
variableEntry ve_basic(std::string name, int type, bool isConst);
variableEntry ve_basic_notInit(std::string name, int type, bool isConst);
variableEntry ve_arr(std::string name, int type, bool isConst, int arrSize);

// Per table, store their name and variableEntry array.
typedef struct {
	std::string scopeName;
	std::vector<variableEntry> variableEntries;
} symbolTable;

class symbolTables
{
private:
	std::vector<symbolTable> tables;					// stack of symbolTable
public:
	symbolTables();

	int push_table(std::string name);					// Push table.
	int pop_table();									// Pop out and show.
	int show_topTable();								// Show top table.

	bool isNowGlobal();									// Check is now global.

	int addVariable(variableEntry var);					// Add variableEntry to top table.
	int editVariable(variableEntry var);				// Edit same name variableEntry in top table.

	int addRetToPreloadFN(int type);					// For function, edit its return type.
	int addArgToPreloadFN(int type);					// For function, edit its argument type.
	variableEntry nowFuncVE();

	variableEntry lookup(std::string name);				// Look up from top table to bottom.
	variableEntry lookupForNowScope(std::string name);	// Look up top table.
};

#endif