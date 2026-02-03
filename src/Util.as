uint64     latestNandoRequest   = 0;
const uint nandoRequestWaitTime = 1000;

void FilterMaps() {
    if (true
        and mapSearch.Length == 0
        and authorSearch.Length == 0
    ) {
        mapsFiltered = maps;
        return;
    }

    const string mapSearchLower = mapSearch.ToLower();
    const string authorSearchLower = authorSearch.ToLower();

    mapsFiltered = {};

    for (uint i = 0; i < maps.Length; i++) {
        Map@ map = maps[i];
        const string authorName = accounts.Exists(map.authorId) ? string(accounts[map.authorId]) : "";

        if (true
            and (false
                or mapSearchLower.Length == 0
                or map.nameClean.ToLower().Contains(mapSearchLower)
            )
            and (false
                or authorSearchLower.Length == 0
                or authorName.ToLower().Contains(authorSearchLower)
            )
        ) {
            mapsFiltered.InsertLast(map);
        }
    }
}

void NandoRequestWait() {
    if (latestNandoRequest == 0) {
        latestNandoRequest = Time::Now;
        return;
    }

    while (Time::Now - latestNandoRequest < nandoRequestWaitTime) {
        yield();
    }

    latestNandoRequest = Time::Now;
}

void PlayRandomMap() {
    if (false
        or !permissionPlayLocal
        or maps.Length == 0
    ) {
        return;
    }

    string currentUid;

    auto App = cast<CTrackMania>(GetApp());

    if (true
        and App.RootMap !is null
        and App.Editor is null
    ) {
        currentUid = App.RootMap.EdChallengeId;
    }

    if (true
        and maps.Length == 1
        and maps[0].uid == currentUid
    ) {
        return;
    }

    int index = Math::Rand(0, int(maps.Length));

    Map@ map = maps[index];

    if (map.uid == currentUid) {
        if (index++ == int(maps.Length - 1)) {
            index = 0;
        }

        @map = maps[index];
    }

    map.Play();
}

// courtesy of "BetterTOTD" plugin - https://github.com/XertroV/tm-better-totd
void ReturnToMenu() {
    auto App = cast<CTrackMania>(GetApp());

    if (App.Network.PlaygroundClientScriptAPI.IsInGameMenuDisplayed) {
        App.Network.PlaygroundInterfaceScriptHandler.CloseInGameMenu(
            CGameScriptHandlerPlaygroundInterface::EInGameMenuResult::Quit
        );
    }

    App.BackToMainMenu();

    while (!App.ManiaTitleControlScriptAPI.IsReady) {
        yield();
    }
}
