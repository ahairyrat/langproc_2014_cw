
#ifndef __C_COMPILER_REGISTER_MANAGER
#define __C_COMPILER_REGISTER_MANAGER
#endif

#include <list>

#define NO_REGISTERS 12

struct ListNode{
	InstructionData data; //TO-DO add instruction information
	int TimeSinceUse;
};

class RegisterManager
{
public:
	RegisterManager();

	unsigned allocate(InstructionData data);
	void deallocate(InstructionData data);

	virtual ~RegisterManager();
private:

	unsigned findLRU();

	void store(unsigned reg, ListNode node);
	void load(unsigned reg);

	std::list<ListNode>* registers[NO_REGISTERS] = { NULL };
};

