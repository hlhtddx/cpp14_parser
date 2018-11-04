/* Multi-line comment
 * Multi-line comment
 */ //Single-line comment

// Single comment

//#include <stdlib.h>
//#include <string.h>
//#include <string>
int strlen(const char*);

int a = 1;
int main(int argc, const char* argv[]) {
	const char* a = "";
	int b = 0x1;
	int c = 0123;
	int d = 1.0f;
	int e = 2UL;
	return strlen(argv[0]);
}

[ [ no_return, abc ]  ] void f(int y [[csdff]]) {
	throw "error"; // OK
}

using namespace std;
class string {
};

class Project {
	string engine;
	string packages;
};

class Id {
	int __id__;
	void write_value() {
		int b =  __id__;
	}
};
