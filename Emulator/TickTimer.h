#pragma once

#include <windows.h>
#include <inttypes.h>
#include <set>
#include <functional>

class TickTimer
{
public:
	TickTimer();
	~TickTimer();

	void AddTimer(int64_t ticks, int64_t interval, std::function<void(DWORD)>, DWORD data);
	bool RemoveTimer(DWORD data);
	void Clear();
	void onTicks(int64_t ticks);

private:
	struct TickHandler {
		int64_t ticks;
		int64_t interval;
		std::function<void(DWORD)> handler;
		DWORD data;
	};
	struct CompareTimePoint {
		inline bool operator()(const TickHandler& left, const TickHandler& right) const {
			return left.ticks < right.ticks || left.data < right.data;
		}
	};

	std::set<TickHandler, CompareTimePoint> tickHandlers;
};

