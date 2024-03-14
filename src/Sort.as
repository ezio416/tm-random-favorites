// c 2024-01-30
// m 2024-01-30

// most things here are courtesy of "BetterTOTD" plugin - https://github.com/XertroV/tm-better-totd
namespace Sort {
    uint64       lastYield    = 0;
    const uint64 maxFrameTime = 10;
    bool         sorting      = false;
    SortMethod   sortMethod   = SortMethod::LatestAddedFirst;

    funcdef int MapSortFunc(Map@ m1, Map@ m2);

    int NameAlpha(Map@ m1, Map@ m2) {
        string n1 = m1.nameClean.Trim().ToLower();
        string n2 = m2.nameClean.Trim().ToLower();

        if (n1 < n2)
            return -1;
        if (n1 > n2)
            return 1;
        return 0;
    }

    int NameAlphaRev(Map@ m1, Map@ m2) {
        string n1 = m1.nameClean.Trim().ToLower();
        string n2 = m2.nameClean.Trim().ToLower();

        if (n1 < n2)
            return 1;
        if (n1 > n2)
            return -1;
        return 0;
    }

    int EarliestAddedFirst(Map@ m1, Map@ m2) {
        return Math::Clamp(m2.number - m1.number, 1, 1);
    }

    int LatestAddedFirst(Map@ m1, Map@ m2) {
        return Math::Clamp(m1.number - m2.number, 1, 1);
    }

    enum SortMethod {
        NameAlpha,
        NameAlphaRev,
        EarliestAddedFirst,
        LatestAddedFirst
    }

    MapSortFunc@[] sortFunctions = {
        NameAlpha,
        NameAlphaRev,
        EarliestAddedFirst,
        LatestAddedFirst
    };

    Map@[] QuickSort(Map@[]@ arr, MapSortFunc@ f, int left = 0, int right = -1) {
        uint64 now = Time::Now;
        if (now - lastYield > maxFrameTime) {
            lastYield = now;
            yield();
        }

        if (right < 0)
            right = arr.Length - 1;

        if (arr.Length == 0)
            return arr;

        int i = left;
        int j = right;
        Map@ pivot = arr[(left + right) / 2];

        while (i <= j) {
            while (f(arr[i], pivot) < 0)
                i++;

            while (f(arr[j], pivot) > 0)
                j--;

            if (i <= j) {
                Map@ temp = arr[i];
                @arr[i] = arr[j];
                @arr[j] = temp;
                i++;
                j--;
            }
        }

        if (left < j)
            arr = QuickSort(arr, f, left, j);

        if (i < right)
            arr = QuickSort(arr, f, i, right);

        return arr;
    }

    void Maps() {
        while (sorting)
            yield();

        sorting = true;

        trace("sorting maps");

        mapsSorted.RemoveRange(0, mapsSorted.Length);

        for (uint i = 0; i < mapsFiltered.Length; i++)
            mapsSorted.InsertLast(mapsFiltered[i]);

        lastYield = Time::Now;

        mapsSorted = QuickSort(mapsSorted, sortFunctions[sortMethod]);

        trace("sorting maps done");

        sorting = false;
    }
}
