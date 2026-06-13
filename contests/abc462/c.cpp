import std;

#ifdef LOCAL
#define debug(x) std::cerr << #x << " = " << (x) << '\n'
#else
#define debug(x)
#endif

struct Position {
    int x;
    int y;
};

int main() {
    int N, count = 0;
    int min = std::numeric_limits<int>::max();
    std::cin >> N;
    std::vector<Position> positions(N);
    for (int i=0; i<N; i++) {
        std::cin >> positions[i].x >> positions[i].y;
    }
    std::sort(positions.begin(), positions.end(), [](const Position& a, const Position& b) {
        return a.x < b.x;
    });
    for (int i=0; i<N; i++) {
        #ifdef LOCAL
        std::cerr << positions[i].x << ":" << positions[i].y << '\n';
        #endif
        if (min > positions[i].y) min = positions[i].y;
        if (min >= positions[i].y) count++;
    }
    std::cout << count << '\n';
}
