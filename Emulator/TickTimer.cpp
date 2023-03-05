#include "TickTimer.h"

#include <algorithm>
#include <vector>

TickTimer::TickTimer()
{
}


TickTimer::~TickTimer()
{
}

void TickTimer::AddTimer(int64_t ticks, std::function<void(DWORD)> handler, DWORD data) {
	TickHandler tp = {
		ticks,
		handler,
		data
	};
	tickHandlers.insert(tp);
}

bool TickTimer::RemoveTimer(DWORD data) {
	const auto iterPos = std::find_if(tickHandlers.cbegin(), tickHandlers.cend(),
		[data](const TickHandler& th) { return th.data == data; }
	);
	if (iterPos == tickHandlers.cend()) return false;
	tickHandlers.erase(iterPos);
	return true;
}

void TickTimer::onTicks(int64_t ticks) {
	std::vector<TickHandler> elapsed;
	int countToDelete = 0;
	for (const TickHandler& th : tickHandlers) {
		if (th.ticks > ticks) break;
		
		elapsed.push_back(th);
		countToDelete += 1;
	}

	for (int n = 0; n < countToDelete; n++) {
		tickHandlers.erase(tickHandlers.cbegin());
	}

	for (const TickHandler& th : elapsed) {
		th.handler(th.data);
	}
}

void TickTimer::Clear() {
	tickHandlers.clear();
}
