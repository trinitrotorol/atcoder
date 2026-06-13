import std;

#ifdef LOCAL
#define debug(x) std::cerr << #x << " = " << (x) << '\n'
#else
#define debug(x)
#endif

struct Person {
    int s;
    int t;
}

int main() {
    int N, D;
    std::cin >> N >> D;
    std::vector<Person> persons(N);
    for (int i=0; i<N; i++) {
        std::cin >> persons[i].s >> persons[i].t;
    }
}
