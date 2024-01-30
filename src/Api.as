// c 2024-01-29
// m 2024-01-30

bool confirmed        = true;
int  offset           = 0;
Map@ selectedFavorite;
bool showConfirmation = false;

void FavoriteAdd() {
    trace("adding favorite map " + selectedFavorite.nameQuoted);

    while (!NadeoServices::IsAuthenticated(audienceLive))
        yield();

    Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
    while (coro.IsRunning())
        yield();

    Net::HttpRequest@ req = NadeoServices::Post(
        audienceLive,
        NadeoServices::BaseURLLive() + "/api/token/map/favorite/" + selectedFavorite.uid + "/add"
    );
    req.Start();
    while (!req.Finished())
        yield();

    int code = req.ResponseCode();
    string text = req.String();
    if (code < 200 || code >= 400) {
        warn("FavoriteAdd: bad response (" + code + "): " + req.Error() + " " + text);
        return;
    }

    selectedFavorite.favorite = true;

    trace("FavoriteAdd response: " + text);
    trace("adding favorite map " + selectedFavorite.nameQuoted + " done");
}

void FavoriteRemove() {
    confirmed = false;
    showConfirmation = true;

    while (!confirmed) {
        if (!showConfirmation)
            return;

        yield();
    }

    trace("removing favorite map " + selectedFavorite.nameQuoted);

    while (!NadeoServices::IsAuthenticated(audienceLive))
        yield();

    Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
    while (coro.IsRunning())
        yield();

    Net::HttpRequest@ req = NadeoServices::Post(
        audienceLive,
        NadeoServices::BaseURLLive() + "/api/token/map/favorite/" + selectedFavorite.uid + "/remove"
    );
    req.Start();
    while (!req.Finished())
        yield();

    int code = req.ResponseCode();
    string text = req.String();
    if (code < 200 || code >= 400) {
        warn("FavoriteRemove: bad response (" + code + "): " + req.Error() + " " + text);
        return;
    }

    selectedFavorite.favorite = false;

    trace("FavoriteRemove response: " + text);
    trace("removing favorite map " + selectedFavorite.nameQuoted + " done");
}

void FavoriteToggle() {
    if (getting || selectedFavorite is null)
        return;

    getting = true;

    if (selectedFavorite.favorite)
        FavoriteRemove();
    else
        FavoriteAdd();

    @selectedFavorite = null;
    getting = false;
}

void GetAccountNames() {
    string[] namesToGet;

    string[]@ keys = accounts.GetKeys();
    for (uint i = 0; i < keys.Length; i++) {
        if (string(accounts[keys[i]]) == "")
            namesToGet.InsertLast(keys[i]);
    }

    if (namesToGet.Length == 0)
        return;

    trace("getting names for " + namesToGet.Length + " accounts");

    dictionary@ returned = NadeoServices::GetDisplayNamesAsync(namesToGet);
    keys = returned.GetKeys();
    for (uint i = 0; i < keys.Length; i++)
        accounts[keys[i]] = returned[keys[i]];

    trace("getting names done");
}

void GetFavoriteMaps() {
    if (getting)
        return;

    getting = true;

    trace("getting favorites");

    while (!NadeoServices::IsAuthenticated(audienceLive))
        yield();

    Meta::PluginCoroutine@ coro = startnew(NandoRequestWait);
    while (coro.IsRunning())
        yield();

    Net::HttpRequest@ req = NadeoServices::Get(
        audienceLive,
        NadeoServices::BaseURLLive() + "/api/token/map/favorite?offset=" + offset + "&length=250"
    );
    req.Start();
    while (!req.Finished())
        yield();

    int code = req.ResponseCode();
    string text = req.String();
    if (code != 200) {
        warn("GetFavoriteMaps: bad response (" + code + "): " + req.Error() + " " + text);
        getting = false;
        return;
    }

    try {
        Json::Value@ parsed = Json::Parse(text);
        Json::Value@ mapList = parsed["mapList"];

        maps.RemoveRange(0, maps.Length);

        for (uint i = 0; i < mapList.Length; i++) {
            Map@ map = Map(mapList[i]);
            maps.InsertLast(map);

            if (!accounts.Exists(map.authorId))
                accounts[map.authorId] = "";
        }

        GetAccountNames();

        int count = parsed["itemCount"];
        if (count > 250) {  // todo
            warn("you have " + count + " favorites - anything added before the last 250 maps can be accessed in a future plugin update");
        }
    } catch {
        warn("GetFavoriteMaps exception: " + getExceptionInfo());
    }

    trace("getting favorites done (" + maps.Length + ")");

    getting = false;
}