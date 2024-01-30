// c 2024-01-29
// m 2024-01-30

dictionary@  accounts            = dictionary();
const string audienceLive        = "NadeoLiveServices";
string       authorSearch;
bool         getting             = false;
bool         loadingMap          = false;
Map@[]       maps;
Map@[]       mapsFiltered;
string       mapSearch;
bool         permissionPlayLocal = false;
const float  scale               = UI::GetScale();
const vec2   confirmButtonSize   = vec2(scale * 110.0f, scale * 25.0f);
const int    confirmWindowX      = int((Draw::GetWidth() / 2 - confirmButtonSize.x - 19.0f) / scale);
const int    confirmWindowY      = int((Draw::GetHeight() / 2 - 200.0f) / scale);
const string title               = "\\$FF0" + Icons::Random + "\\$G Random Favorites";

void Main() {
    NadeoServices::AddAudience(audienceLive);

    if (Permissions::PlayLocalMap())
        permissionPlayLocal = true;
    else {
        warn("Club access required to play maps");

        if (S_NotifyStarter)
            UI::ShowNotification(title, "Club access is required to play maps, but you can still see the list of your favorites", vec4(1.0f, 0.1f, 0.1f, 0.8f));
    }

    accounts["d2372a08-a8a1-46cb-97fb-23a161d85ad0"] = "Nadeo";

    if (S_Auto)
        startnew(GetFavoriteMaps);
}

void RenderMenu() {
    if (UI::BeginMenu(title)) {
        if (UI::MenuItem(Icons::WindowRestore + " Show window", "", S_Show))
            S_Show = !S_Show;

        if (UI::MenuItem(Icons::Refresh + " Refresh favorites (" + maps.Length + ")", "", false, !getting))
            startnew(GetFavoriteMaps);

        if (UI::MenuItem(Icons::Play + " Play random map", "", false, !getting && permissionPlayLocal && maps.Length > 0 && !loadingMap))
            startnew(PlayRandomMap);

        UI::EndMenu();
    }
}

void Render() {
    RenderConfirmation();

    if (
        !S_Show ||
        (S_HideWithGame && !UI::IsGameUIVisible()) ||
        (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    UI::SetNextWindowSize(650, 300, UI::Cond::FirstUseEver);

    UI::Begin(title, S_Show, UI::WindowFlags::None);
        UI::BeginDisabled(getting);
        if (UI::Button(Icons::Refresh + " Refresh favorites (" + maps.Length + ")"))
            startnew(GetFavoriteMaps);
        UI::EndDisabled();

        UI::SameLine();
        UI::BeginDisabled(getting || !permissionPlayLocal || maps.Length == 0 || loadingMap);
        if (UI::Button(Icons::Play + " Play random map"))
            startnew(PlayRandomMap);
        UI::EndDisabled();

        if (S_MapSearch) {
            mapSearch = UI::InputText("search maps", mapSearch, false);

            if (mapSearch != "") {
                UI::SameLine();
                if (UI::Button(Icons::Times + " Clear Search##mapSearchClear"))
                    mapSearch = "";

                UI::SameLine();
                UI::Text(mapsFiltered.Length + " result" + (mapsFiltered.Length == 1 ? "" : "s"));
            }
        } else
            mapSearch = "";

        if (S_AuthorSearch) {
            authorSearch = UI::InputText("search authors", authorSearch, false);

            if (authorSearch != "") {
                UI::SameLine();
                if (UI::Button(Icons::Times + " Clear Search##authorSearchClear"))
                    authorSearch = "";

                UI::SameLine();
                UI::Text(mapsFiltered.Length + " result" + (mapsFiltered.Length == 1 ? "" : "s"));
            }
        } else
            authorSearch = "";

        FilterMaps();

        UI::Text("Click a map name to play it:");

        if (UI::BeginTable("##map-table", S_Hearts ? 7 : 6, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, vec4(0.0f, 0.0f, 0.0f, 0.5f));

            UI::TableSetupScrollFreeze(0, 1);
            if (S_Hearts)
                UI::TableSetupColumn("fav",    UI::TableColumnFlags::WidthFixed, scale * 35.0f);
            UI::TableSetupColumn("name");
            UI::TableSetupColumn("author",     UI::TableColumnFlags::WidthFixed, scale * 120.0f);
            UI::TableSetupColumn("authorTime", UI::TableColumnFlags::WidthFixed, scale * 75.0f);
            UI::TableSetupColumn("goldTime",   UI::TableColumnFlags::WidthFixed, scale * 75.0f);
            UI::TableSetupColumn("silverTime", UI::TableColumnFlags::WidthFixed, scale * 75.0f);
            UI::TableSetupColumn("bronzeTime", UI::TableColumnFlags::WidthFixed, scale * 75.0f);
            UI::TableHeadersRow();

            UI::ListClipper clipper(mapsFiltered.Length);
            while (clipper.Step()) {
                for (int i = clipper.DisplayStart; i < clipper.DisplayEnd; i++) {
                    Map@ map = mapsFiltered[i];

                    UI::TableNextRow();

                    if (S_Hearts) {
                        UI::TableNextColumn();
                        UI::BeginDisabled(getting);
                        string icon = map.favorite ? Icons::Heart : Icons::HeartO;
                        if (UI::Button(icon + "##" + map.uid, Draw::MeasureString(icon) + vec2(scale * 15.0f, scale * 10.0f))) {
                            @selectedFavorite = map;
                            startnew(FavoriteToggle);
                        }
                        UI::EndDisabled();
                    }

                    UI::TableNextColumn();
                    UI::BeginDisabled(!permissionPlayLocal || loadingMap);
                    if (UI::Selectable(S_ColorMapNames ? map.nameColored : map.nameClean, false))
                        startnew(CoroutineFunc(map.Play));
                    UI::EndDisabled();

                    UI::TableNextColumn();
                    UI::Text(accounts.Exists(map.authorId) ? string(accounts[map.authorId]) : "");

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.authorTime));

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.goldTime));

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.silverTime));

                    UI::TableNextColumn();
                    UI::Text(Time::Format(map.bronzeTime));
                }
            }

            UI::PopStyleColor();
            UI::EndTable();
        }

    UI::End();
}

void RenderConfirmation() {
    if (!showConfirmation || selectedFavorite is null)
        return;

    UI::SetNextWindowPos(confirmWindowX, confirmWindowY);

    UI::Begin(title + " Confirmation", showConfirmation, UI::WindowFlags::NoTitleBar | UI::WindowFlags::AlwaysAutoResize);
        UI::Text("Are you sure you want to remove the\nfollowing map from your favorites?\nIt may be difficult to find again:");
        UI::TextWrapped(selectedFavorite.nameQuoted + "\n");

        if (UI::ButtonColored("YES", 0.35f, 1.0f, 0.6f, confirmButtonSize)) {
            confirmed = true;
            showConfirmation = false;
        }

        UI::SameLine();
        if (UI::ButtonColored("NO", 0.0f, 1.0f, 0.6f, confirmButtonSize))
            showConfirmation = false;

    UI::End();
}