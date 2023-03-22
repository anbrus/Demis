#include "stdafx.h"
#include "Listing.h"

#include <fstream>
#include <algorithm>

Listing::Listing() {

}

Listing::~Listing() {

}

bool Listing::Parse(const std::string& pathLst) {
    isCodeSegment = false;

    std::ifstream file;
    file.open(pathLst);

    if (!file.is_open()) {
        return false;
    }

    std::string str;
    while (getline(file, str)) {
        OemToChar(str.c_str(), str.data());
        std::optional<Listing::Line> line = parseLine(str);
        if(line) lines[line->address] = *line;
    }

    return true;
}

static const std::string spaces = "        ";

static std::string expandTabs(const std::string& s) {
    std::string res;

    int posPrev = 0;
    while (true) {
        const auto iterTab = std::find(s.cbegin() + posPrev, s.cend(), '\t');
        if (iterTab == s.cend()) {
            res += s.substr(posPrev);
            break;
        }
        int posTab = iterTab - s.cbegin();
        res += s.substr(posPrev, posTab - posPrev);
        int countSpaces = 8 - res.length() % 8;
        res += spaces.substr(8 - countSpaces);
        posPrev = posTab+1;
    }

    return res;
}

std::optional<Listing::Line> Listing::parseLine(const std::string& str) {
    std::string strLocal = expandTabs(str);
    if (strLocal.length() < 32) return {};

    std::string lower = strLocal;
    std::transform(lower.cbegin(), lower.cend(), lower.begin(), std::tolower);
    if (lower.find("code") != std::string::npos) {
        if (lower.find("segment") != std::string::npos) {
            isCodeSegment = true;
        }
        else if (lower.find("ends") != std::string::npos) {
            std::string strAddress = strLocal.substr(0, 5);
            int address = 0;
            int scanned = sscanf_s(strAddress.c_str(), "%X", &address);
            if (scanned == 1) {
                sizeCodeSeg = ((address + 15) / 16) * 16;
            };
            isCodeSegment = false;
        }
    }

    if (!isCodeSegment) return {};

    std::string address = strLocal.substr(0, 5);

    Line line;
    int scanned = sscanf_s(address.c_str(), "%X", &line.address);
    if (scanned < 1) return {};
    line.comment = strLocal.substr(32);
    return line;
}

void Listing::Clear() {
    lines.clear();
}

std::optional<std::string> Listing::GetComment(DWORD seg, DWORD offs) {
    int addr = seg * 16 + offs;
    int offsetCode = addr - (0x100000 - sizeCodeSeg);
    const auto iter = lines.find(offsetCode);
    if (iter == lines.cend()) return {};
    return iter->second.comment;
}