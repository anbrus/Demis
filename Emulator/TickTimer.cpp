#include "TickTimer.h"

#include <algorithm>
#include <vector>

TickTimer::TickTimer()
{
}


TickTimer::~TickTimer()
{
}

void TickTimer::AddTimer(int64_t ticks, int64_t interval, std::function<void(DWORD)> handler, DWORD data) {
	TickHandler tp = {
		ticks,
		interval,
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
	std::vector<TickHandler> toRepeat;
	int countToDelete = 0;
	for (const TickHandler& th : tickHandlers) {
		if (th.ticks > ticks) break;
		
		th.handler(th.data);
		if(th.interval>0)
			toRepeat.push_back(th);
		countToDelete++;
	}

	for (int n = 0; n < countToDelete; n++) {
		tickHandlers.erase(tickHandlers.cbegin());
	}

	for (TickHandler th : toRepeat) {
		while(th.ticks < ticks)
			th.ticks += th.interval;
		tickHandlers.insert(th);
	}
}

void TickTimer::Clear() {
	tickHandlers.clear();
}
