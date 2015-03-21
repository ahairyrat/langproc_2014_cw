
#ifndef __C_COMPILER_REGISTER_MANAGER
#define __C_COMPILER_REGISTER_MANAGER

#include <deque>
#include <string>
#include <exception>

//Register 12 is used as the base for memory locations
#define NO_REGISTERS 11

struct InstructionData{
	std::string variableName;
	unsigned registerLocation;
	unsigned memoryLocation;
};

struct ListNode{
	bool valid;
	InstructionData data;
	int TimeSinceUse;
};

class RegisterAllocationException
{

};

class MemoryAllocationException
{

};

class RegisterManager
{
public:
	RegisterManager();

	unsigned allocate(std::string variableName);
	void deallocate(std::string variableName);

	InstructionData* get(std::string variableName);
	
	void printRegisters();

	virtual ~RegisterManager();

private:
	unsigned findLRU();
	
	int freeMemoryLoc;

	int getRegister(std::string variableName);

	int getMemory(std::string variableName);

	void store(ListNode node, unsigned reg);
	void load(std::string variableName, unsigned reg);
	
	void increment(int reg);

	ListNode registers[NO_REGISTERS];

	std::deque < ListNode > memory;
};

#endif