// c 2024-01-29
// m 2024-01-30

class Map {
    string authorId;
    uint   authorTime;
    uint   bronzeTime;
    string downloadUrl;
    bool   favorite;
    uint   goldTime;
    string id;
    uint   laps;
    string nameClean;
    string nameColored;
    string nameQuoted;
    string nameRaw;
    int    number;
    uint   silverTime;
    string submitterId;
    string thumbnailUrl;
    string uid;
    uint   updateTimestamp;
    uint   uploadTimestamp;

    Map() { }
    // Map(const string &in uid) { this.uid = uid; }
    Map(Json::Value@ json) {
        authorId        = json["author"];
        authorTime      = json["authorTime"];
        bronzeTime      = json["bronzeTime"];
        downloadUrl     = json["downloadUrl"];
        favorite        = json["favorite"];
        goldTime        = json["goldTime"];
        id              = json["mapId"];
        laps            = json["nbLaps"];
        nameRaw         = json["name"];
        silverTime      = json["silverTime"];
        submitterId     = json["submitter"];
        thumbnailUrl    = json["thumbnailUrl"];
        uid             = json["uid"];
        updateTimestamp = json["updateTimestamp"];
        uploadTimestamp = json["uploadTimestamp"];

        SetNames();
    }

    // courtesy of "Play Map" plugin - https://github.com/XertroV/tm-play-map
    void Play() {
        if (loadingMap || !permissionPlayLocal)
            return;

        loadingMap = true;

        trace("loading map " + nameQuoted + " for playing");

        ReturnToMenu();

        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        App.ManiaTitleControlScriptAPI.PlayMap(downloadUrl, "TrackMania/TM_PlayMap_Local", "");

        const uint64 waitToPlayAgain = 5000;
        const uint64 now = Time::Now;

        while (Time::Now - now < waitToPlayAgain)
            yield();

        loadingMap = false;
    }

    void SetNames() {
        nameRaw = nameRaw.Trim();
        nameClean = StripFormatCodes(nameRaw).Trim();
        nameColored = ColoredString(nameRaw).Trim();
        nameQuoted = "\"" + nameClean + "\"";
    }

    Json::Value@ ToJson() {
        Json::Value@ ret;

        ret["authorId"]        = authorId;
        ret["authorTime"]      = authorTime;
        ret["bronzeTime"]      = bronzeTime;
        ret["downloadUrl"]     = downloadUrl;
        ret["favorite"]        = favorite;
        ret["goldTime"]        = goldTime;
        ret["id"]              = id;
        ret["nameClean"]       = nameClean;
        ret["nameColored"]     = nameColored;
        ret["nameQuoted"]      = nameQuoted;
        ret["nameRaw"]         = nameRaw;
        ret["laps"]            = laps;
        ret["silverTime"]      = silverTime;
        ret["submitterId"]     = submitterId;
        ret["thumbnailUrl"]    = thumbnailUrl;
        ret["uid"]             = uid;
        ret["updateTimestamp"] = updateTimestamp;
        ret["uploadTimestamp"] = uploadTimestamp;

        return ret;
    }

    string ToString() {
        return Json::Write(ToJson());
    }
}