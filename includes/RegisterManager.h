#ifndef __C_COMPILER_REGISTER_MANAGER_H
#define __C_COMPILER_REGISTER_MANAGER_H

#include <deque>
#include <string>
#include <vector>
#include "../includes/CodeGenerator.h"

//Register 12 is used as the base for memory locations
#define NO_REGISTERS 12

struct InstructionData {
	std::string variableName;
	unsigned registerLocation;
	unsigned memoryLocation;
};

struct ListNode {
	bool valid;
	InstructionData data;
	int TimeSinceUse;
};

class RegisterAllocationException {

};

class MemoryAllocationException {

};

class RegisterManager {
public:
	RegisterManager(CodeGenerator *codeGenerator);

	unsigned allocate(std::string variableName);
	unsigned allocate(std::string variableName, int regVal);
	void deallocate(std::string variableName);

	void allocateSubroutine(std::vector<std::string> &parameters);
	void deallocateSubroutine();

	InstructionData* get(std::string variableName);

	void printRegisters();

	virtual ~RegisterManager();

	void storeStack(ListNode node, unsigned reg);
	//popping of the stack
	ListNode & loadStack(unsigned reg);
	//popping off the stack with aliasing
	ListNode & loadStack(unsigned reg, std::string name);

	void aliasRegisters(std::vector<std::string> &alias);
	void restoreAliasRegisters();

	void invalidateLocalRegisters();

	int getMemory(std::string variableName);

private:
	unsigned findLRU();

	int freeMemoryLoc;

	int getRegister(std::string variableName);

	void store(ListNode node, unsigned reg);

	void load(std::string variableName, unsigned reg);

	void increment(int reg);

	ListNode registers[NO_REGISTERS];

	std::deque<ListNode> memory;

	std::deque<ListNode> stack;

	CodeGenerator *codeGenerator;

	int globalMemoryLocation;

	std::vector<std::string> alias[4];
};

#endif
