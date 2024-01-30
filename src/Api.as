// c 2024-01-29
// m 2024-01-30

int offset = 0;

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
        warn("bad response (" + code + "): " + req.Error() + " " + text);
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