// c 2024-01-29
// m 2024-01-30

class Map {
    string authorId;
    string authorName;
    uint   authorTime;
    uint   bronzeTime;
    string downloadUrl;
    uint   goldTime;
    string id;
    string nameClean;
    string nameColored;
    string nameQuoted;
    string nameRaw;
    uint   nbLaps;
    uint   silverTime;
    string submitter;
    string thumbnailUrl;
    string uid;
    uint   updateTimestamp;
    uint   uploadTimestamp;

    Map() { }
    Map(Json::Value@ json) {
        authorId        = json["author"];
        authorTime      = json["authorTime"];
        bronzeTime      = json["bronzeTime"];
        downloadUrl     = json["downloadUrl"];
        goldTime        = json["goldTime"];
        id              = json["mapId"];
        nameRaw         = json["name"];
        nbLaps          = json["nbLaps"];
        silverTime      = json["silverTime"];
        submitter       = json["submitter"];
        thumbnailUrl    = json["thumbnailUrl"];
        uid             = json["uid"];
        updateTimestamp = json["updateTimestamp"];
        uploadTimestamp = json["uploadTimestamp"];

        SetNames();
    }

    // courtesy of "Play Map" plugin - https://github.com/XertroV/tm-play-map
    void Play() {
        if (loadingMap || !canPlay)
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
}