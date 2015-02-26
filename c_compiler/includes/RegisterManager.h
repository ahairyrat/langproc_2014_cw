
#ifndef __C_COMPILER_REGISTER_MANAGER
#define __C_COMPILER_REGISTER_MANAGER
#endif

#include <list>

#define NO_REGISTERS 12

struct InstructionData{
	std::string variableName;
	unsigned memoryLocation;
	int value;
};

struct ListNode{
	bool valid;
	InstructionData data;
	int TimeSinceUse;
};

class RegisterManager
{
public:
	RegisterManager();

	unsigned allocate(std::string variableName);
	unsigned allocate(std::string variableName, int value);
	void deallocate(std::string variableName);

	virtual ~RegisterManager();
private:

	unsigned findLRU();

	void store(unsigned reg, ListNode node);
	void load(unsigned reg);

	ListNode registers[NO_REGISTERS];

	std::list < ListNode > memory;
};

