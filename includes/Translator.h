#ifndef __C_COMPILER_TRANSLATOR_H
#define __C_COMPILER_TRANSLATOR_H

#include "../includes/FlexDef.h"
#include "../includes/RegisterManager.h"
#include "../includes/CodeGenerator.h"
#include <fstream>

class Translator {
public:
	Translator(abstractNode* &root, std::string outputFile);
	virtual ~Translator();

	void setRoot(abstractNode* root);

	bool translate();

private:
	RegisterManager* registerManager;
	CodeGenerator* codeGenerator;

	abstractNode* root;

	int tempVal;

	int labelVal;

	bool translateNode(abstractNode* node);

	std::string generateTempName(abstractNode*);

	std::string generateLabel();
};

#endif

