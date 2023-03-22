#pragma once

#include <string>
#include <unordered_map>
#include <optional>

class Listing
{
public:
	Listing();
	virtual ~Listing();

	bool Parse(const std::string& pathLst);
	void Clear();
	std::optional<std::string> GetComment(DWORD seg, DWORD offs);

private:
	int sizeCodeSeg = 0;

	struct Line {
		DWORD address;
		std::string comment;
	};
	std::unordered_map<DWORD, Line> lines;
	bool isCodeSegment = false;

	std::optional<Listing::Line> parseLine(const std::string& str);
};

