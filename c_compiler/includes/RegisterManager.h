
#ifndef __C_COMPILER_REGISTER_MANAGER
#define __C_COMPILER_REGISTER_MANAGER
#endif

#include <deque>

#define NO_REGISTERS 12

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

class RegisterAllocationException : _exception
{

};

class MemoryAllocationException : _exception
{

};

class RegisterManager
{
public:
	RegisterManager();

	unsigned allocate(std::string variableName);
	void deallocate(std::string variableName);

	InstructionData* get(std::string variableName);

	virtual ~RegisterManager();

private:
	unsigned findLRU();

	int getRegister(std::string variableName);

	int getMemory(std::string variableName);

	void store(ListNode node, unsigned reg);
	void load(std::string variableName, unsigned reg);

	ListNode registers[NO_REGISTERS];

	std::deque < ListNode > memory;
};

