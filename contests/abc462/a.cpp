import std;

int main() {
    std::string S;
    std::getline(std::cin, S);
    for (char c : S) {
        if ('0' <= c && c <= '9') {
            std::cout << c;
        }
    }
    std::cout << '\n';
}
