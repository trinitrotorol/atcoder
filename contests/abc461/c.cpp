import std;

struct Jem {
    int color;
    int value;
};

int main() {
    int N, K, M;
    std::cin >> N >> K >> M;
    std::vector<Jem> jems(N);
    for (int i : std::views::iota(0, N)) {
        std::cin >> jems[i].color >> jems[i].value;
    }

    // sort
    std::ranges::sort(jems, std::ranges::greater{}, &Jem::value);

    // unique filter
    std::unordered_set<int> unique_colors;
    for (const auto& jem : jems | std::views::take(K)) {
        unique_colors.insert(jem.color);
    }

    // condition check
    int idx = 1, swap_count = 0;
    while ((int)unique_colors.size() + swap_count < M) {
        if (std::ranges::count(jems, jems[K-idx].color, &Jem::color) != 1) {
            auto it = std::find_if(jems.begin() + K + swap_count, jems.end(), [&](const Jem& jem) {
                return jem.color != jems[K-idx].color;
            });
            std::swap(jems[K-idx], jems[it - jems.begin()]);
            idx++;
            swap_count++;
        }
        else {
            idx++;
        }
    }

    long long sum = 0;
    for (int i = 0; i < K; i++) {
        sum += jems[i].value;
    }
    std::cout << sum << '\n';
}
