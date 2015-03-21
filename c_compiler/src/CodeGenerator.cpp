#include "../includes/CodeGenerator.h"

CodeGenerator::CodeGenerator(std::string &outputFile) {
	(this -> outputFileStream).open(outputFile.c_str(), std::ofstream::trunc);
}
;

CodeGenerator::~CodeGenerator() {
	(this -> outputFileStream).close();
}
;

void CodeGenerator::write(ASM_T cmd, int rt, int r1, int r2) {
	switch (cmd) {
	case LDR_ASM:
		outputFileStream << "LDR R" << rt << ", [R" << r1 << ", #" << r2 << " ]"
		<< std::endl;
		break;
	case STR_ASM:
		outputFileStream << "STR R" << rt << ", [R" << r1 << ", #" << r2 << " ]"
		<< std::endl;
		break;
	case MOV_ASM:
		outputFileStream << "MOV R" << rt << ", R" << r1 << std::endl;
		break;
	case MOVI_ASM:
		outputFileStream << "MOV R" << rt << ", #" << r1 << std::endl;
		break;
	case ADD_ASM:
		outputFileStream << "ADD R" << rt << ", R" << r1 << ", R" << r2 << std::endl;
		break;
	case SUB_ASM:
		outputFileStream << "SUB R" << rt << ", R" << r1 << ", R" << r2 << std::endl;
		break;
	case MULT_ASM:
		outputFileStream << "MULT R" << rt << ", R" << r1 << ", R" << r2 << std::endl;
		break;
	case DIV_ASM:
		outputFileStream << "SDIV R" << rt << ", R" << r1 << ", R" << r2 << std::endl;
		break;
	}
}
;

